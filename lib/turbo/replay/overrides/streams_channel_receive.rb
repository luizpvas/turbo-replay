module Turbo::Replay
  module Overrides
    module StreamsChannelReceive
      GetCurrentSequenceNumber =
        lambda do |broadcasting, _params|
          sequence_number =
            Message.get_current_sequence_number(broadcasting: broadcasting)

          {sequence_number: sequence_number}
        end

      GetMessagesAfterSequenceNumber =
        lambda do |broadcasting, params|
          messages =
            Message.get_after_sequence_number(
              broadcasting: broadcasting,
              sequence_number: params["sequence_number"]&.to_i
            )

          {messages: messages}
        end

      COMMANDS = {
        "get_current_sequence_number" => GetCurrentSequenceNumber,
        "get_messages_after_sequence_number": GetMessagesAfterSequenceNumber
      }.freeze

      def receive(data)
        cmd_handler =
          COMMANDS[data["cmd"]]

        broadcasting =
          self.class.verified_stream_name(params[:signed_stream_name])

        transmit(cmd_handler.(broadcasting, data)) if cmd_handler.present?
      end
    end
  end
end
