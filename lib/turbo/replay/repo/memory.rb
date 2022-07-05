module Turbo::Replay
  module Repo
    class Memory < Base
      def initialize
        @mutex = Mutex.new
        @counters = {}
        @messages = {}
        @ttl = {}
      end

      def get_current_sequence_number(broadcasting:)
        synchronize(broadcasting) do
          @counters.fetch(broadcasting, 0)
        end
      end

      def get_all_messages(broadcasting:)
        synchronize(broadcasting) do
          @messages.fetch(broadcasting, [])
        end
      end

      def insert_message(broadcasting:, content:, retention:)
        synchronize(broadcasting) do
          @ttl[broadcasting] =
            Time.current + retention.ttl

          next_sequence_number =
            (@counters[broadcasting] = @counters.fetch(broadcasting, 0) + 1)

          content_with_sequence_number =
            {sequence_number: next_sequence_number, content: content}

          (@messages[broadcasting] ||= []).tap do |messages|
            messages << content_with_sequence_number
            messages.shift if messages.length > retention.size
          end

          content_with_sequence_number
        end
      end

      private

      def synchronize(broadcasting)
        @mutex.synchronize do
          delete_cached_data_if_expired(broadcasting)

          yield
        end
      end

      def delete_cached_data_if_expired(broadcasting)
        return if @ttl[broadcasting].nil? || @ttl[broadcasting].after?(Time.current)

        @ttl.delete(broadcasting)
        @counters.delete(broadcasting)
        @messages.delete(broadcasting)
      end
    end
  end
end
