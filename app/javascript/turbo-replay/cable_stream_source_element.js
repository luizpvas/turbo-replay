import { connectStreamSource, disconnectStreamSource } from "@hotwired/turbo"
import { subscribeTo } from "./cable"
import snakeize from "./snakeize"

class TurboCableStreamSourceElement extends HTMLElement {
  async connectedCallback() {
    connectStreamSource(this)

    this.subscription = await subscribeTo(this.channel, {
      connected: this.fetchSequenceNumber.bind(this),
      received: this.dispatchMessageEvent.bind(this)
    })
  }

  disconnectedCallback() {
    disconnectStreamSource(this)
    if (this.subscription) this.subscription.unsubscribe()
  }

  fetchSequenceNumber() {
    console.log('fetch sequence number')
    console.log(this.subscription.send({run: 'fetch_sequence_number'}))
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data: data.data })
    return this.dispatchEvent(event)
  }

  get channel() {
    const channel = this.getAttribute("channel")
    const signed_stream_name = this.getAttribute("signed-stream-name")
    return { channel, signed_stream_name, ...snakeize({ ...this.dataset }) }
  }
}

customElements.define("turbo-cable-stream-source", TurboCableStreamSourceElement)
