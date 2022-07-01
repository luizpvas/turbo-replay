module Turbo::Replay
  module Repo
    class Base
      def get_current_sequence_number(broadcasting:)
        raise NotImplementedError
      end

      def get_all_messages(broadcasting:)
        raise NotImplementedError
      end

      def insert_message(broadcasting:, content:, retention:)
        raise NotImplementedError
      end
    end
  end
end
