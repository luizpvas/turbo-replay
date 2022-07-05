module Turbo::Replay
  module Repo
    class Redis < Base
      attr_reader :client

      INSERT_MESSAGE_LUA_SCRIPT = <<-LUA
        local sequence_number =
          redis.call('INCR', KEYS[1])

        local content_with_sequence_number =
          cjson.encode({ sequence_number=sequence_number, content=KEYS[5] })

        redis.call('LPUSH', KEYS[2], content_with_sequence_number)
        redis.call('LTRIM', KEYS[2], 0, KEYS[3] - 1)

        redis.call('EXPIRE', KEYS[1], KEYS[4])
        redis.call('EXPIRE', KEYS[2], KEYS[4])

        return sequence_number
      LUA

      def initialize(client:)
        @client =
          client

        @insert_message_script_sha =
          @client.script(:load, INSERT_MESSAGE_LUA_SCRIPT)
      end

      def get_current_sequence_number(broadcasting:)
        counter_key =
          FormatCounterKey.call(broadcasting)

        @client.get(counter_key)&.to_i || 0
      end

      def get_all_messages(broadcasting:)
        messages_key =
          FormatMessagesKey.call(broadcasting)

        @client.lrange(messages_key, 0, -1)
          .map(&SafeParseJson)
          .compact
          .reverse
      end

      def insert_message(broadcasting:, content:, retention:)
        counter_key =
          FormatCounterKey.call(broadcasting)

        messages_key =
          FormatMessagesKey.call(broadcasting)

        script_args =
          [counter_key, messages_key, retention.size, retention.ttl, content]

        sequence_number =
          @client.evalsha(@insert_message_script_sha, script_args)

        {sequence_number: sequence_number, content: content}
      end

      private

      PREFIX = "replay"

      FormatCounterKey =
        ->(broadcasting) { "#{PREFIX}:#{broadcasting}:counter" }

      FormatMessagesKey =
        ->(broadcasting) { "#{PREFIX}:#{broadcasting}:messages" }

      SafeParseJson =
        ->(encoded) do
          begin
            JSON.parse(encoded).symbolize_keys
          rescue
            nil
          end
        end
    end
  end
end
