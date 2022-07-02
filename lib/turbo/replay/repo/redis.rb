module Turbo::Replay
  module Repo
    class Redis < Base
      attr_reader :client

      def initialize(client:)
        @client = client
      end

      def get_current_sequence_number(broadcasting:)
        counter_key =
          format_counter_key(broadcasting)

        @client.get(counter_key)&.to_i || 0
      end

      def get_all_messages(broadcasting:)
        messages_key =
          format_messages_key(broadcasting)

        @client.lrange(messages_key, 0, -1)
          .map(&SafeParseJson)
          .filter
          .sort_by(&BySequenceNumber)
      end

      def insert_message(broadcasting:, content:, retention:)
        counter_key =
          format_counter_key(broadcasting)

        messages_key =
          format_messages_key(broadcasting)

        next_sequence_number =
          @client.incr(counter_key)

        content_with_sequence_number =
          {sequence_number: next_sequence_number, content: content}

        @client.lpush(messages_key, content_with_sequence_number.to_json)
        @client.ltrim(messages_key, 0, retention.size - 1)

        @client.expire(counter_key, retention.ttl)
        @client.expire(messages_key, retention.ttl)

        content_with_sequence_number
      end

      private

      PREFIX = "replay"

      SafeParseJson =
        lambda { JSON.parse(_1) rescue nil }

      BySequenceNumber =
        lambda { _1["sequence_number"] }

      def format_counter_key(broadcasting)
        "#{PREFIX}:#{broadcasting}:counter"
      end

      def format_messages_key(broadcasting)
        "#{PREFIX}:#{broadcasting}:messages"
      end
    end
  end
end
