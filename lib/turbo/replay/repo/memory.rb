module Turbo::Replay
  module Repo
    class Memory < Base
      def initialize
        @mutex = Mutex.new
        @counters = {}
        @messages = {}
      end

      def get_current_sequence_number(broadcasting:)
        @mutex.synchronize do
          @counters.fetch(broadcasting, 0)
        end
      end

      def get_all_messages(broadcasting:)
      end

      def insert_message(broadcasting:, content:, retention:)
        @mutex.synchronize do
          next_sequence_number =
            (@counters[broadcasting] = @counters.fetch(broadcasting, 0) + 1)

          content_with_sequence_number =
            {sequence_number: next_sequence_number, content: content}

          @messages[broadcasting] ||= []
          @messages[broadcasting] << content_with_sequence_number

          content_with_sequence_number
        end
      end
    end
  end
end
