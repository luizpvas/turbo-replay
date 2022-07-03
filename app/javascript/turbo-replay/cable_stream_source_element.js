import { connectStreamSource, disconnectStreamSource } from "@hotwired/turbo"
import { subscribeTo } from "./cable"
import snakeize from "./snakeize"

const UNRECOVERABLE_RESULT = "unrecoverable"

class TurboCableStreamSourceElement extends HTMLElement {
  async connectedCallback() {
    connectStreamSource(this)

    this.subscription = await subscribeTo(this.channel, {
      connected: this.fetchSequenceNumber.bind(this),
      received: this.handleMessage.bind(this)
    })
  }

  disconnectedCallback() {
    disconnectStreamSource(this)
    if (this.subscription) this.subscription.unsubscribe()
  }

  fetchSequenceNumber() {
    if (this.sequenceNumber && this.connectedOnce !== undefined) {
      this.replayMissedMessages()
      return
    }

    this.subscription.send({cmd: "get_current_sequence_number"})
  }

  replayMissedMessages() {
    this.subscription.send({
      cmd: "get_messages_after_sequence_number",
      sequence_number: this.sequenceNumber
    })
  }

  handleMessage(data) {
    if (data.get_current_sequence_number !== undefined) {
      return this.handleGetCurrentSequenceNumber(data)
    }

    if (data.get_messages_after_sequence_number !== undefined) {
      return this.handleGetMessagesAfterSequenceNumber(data)
    }

    if (data.sequence_number !== undefined) {
      return this.handleMessageBroadcast(data)
    }
  }

  handleGetCurrentSequenceNumber(data) {
    this.connectedOnce = true
    this.sequenceNumber = data.get_current_sequence_number
  }

  handleGetMessagesAfterSequenceNumber(data) {
    const result =
      data.get_messages_after_sequence_number

    if (Array.isArray(result)) {
      return result.forEach(this.dispatchMessageEvent.bind(this))
    }

    if (result  === UNRECOVERABLE_RESULT) {
      return this.dispatchUnrecoverableEvent()
    }

    throw new Error(`Unexpected result from get_messages_after_sequence_number: ${result}`)
  }

  handleMessageBroadcast(data) {
    const sequenceNumberDoesNotMatchExpectedValue =
      data.sequence_number !== 1 && data.sequence_number !== this.sequenceNumber + 1

    if (sequenceNumberDoesNotMatchExpectedValue) {
      this.replayMissedMessages()

      return
    }

    this.dispatchMessageEvent(data)
  }

  dispatchMessageEvent(data) {
    this.sequenceNumber =
      data.sequence_number

    return this.dispatchEvent(
      new MessageEvent("message", { data: data.content })
    )
  }

  dispatchUnrecoverableEvent() {
    return this.dispatchEvent(
      new CustomEvent("turbo-replay:unrecoverable", {detail: {channel: this.channel}, bubbles: true})
    )
  }

  get channel() {
    const channel = this.getAttribute("channel")
    const signed_stream_name = this.getAttribute("signed-stream-name")
    return { channel, signed_stream_name, ...snakeize({ ...this.dataset }) }
  }
}

customElements.define("turbo-cable-stream-source", TurboCableStreamSourceElement)
