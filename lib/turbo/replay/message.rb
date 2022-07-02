module Turbo::Replay
  module Message
    extend self

    def get_current_sequence_number(broadcasting:)
      Turbo::Replay.configuration.repo.get_current_sequence_number(broadcasting: broadcasting)
    end

    def get_after_sequence_number(broadcasting:, sequence_number:)
      messages =
        Turbo::Replay.configuration.repo
          .get_all_messages(broadcasting: broadcasting)
          .sort_by(&BySequenceNumber)

      return :unrecoverable if IsUnrecoverable.(sequence_number, messages)

      messages.filter(&AfterSequenceNumber[sequence_number])
    end

    def insert(broadcasting:, content:)
      Turbo::Replay.configuration.repo.insert_message(
        broadcasting: broadcasting,
        content: content,
        retention: Turbo::Replay.configuration.retention
      )
    end

    private

    IsUnrecoverable =
      ->(sequence_number, messages) {
        return false if messages.empty?

        sequence_number < messages.first[:sequence_number] - 1
      }

    BySequenceNumber =
      ->(content_with_sequence_number) {
        content_with_sequence_number[:sequence_number]
      }
    
    AfterSequenceNumber =
      ->(sequence_number, content_with_sequence_number) {
        content_with_sequence_number[:sequence_number] > sequence_number
      }.curry
  end
end
