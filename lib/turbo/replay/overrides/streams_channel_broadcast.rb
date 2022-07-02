module Turbo::Replay
  module Overrides
    module StreamsChannelBroadcast
      def broadcast_stream_to(*streamables, content:)
        broadcasting =
          stream_name_from(streamables)

        content_with_sequence_number =
          Turbo::Replay::Message.insert(
            broadcasting: broadcasting,
            content: content
          )

        ::ActionCable.server.broadcast(broadcasting, content_with_sequence_number)
      end
    end
  end
end
