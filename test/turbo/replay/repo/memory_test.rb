require "test_helper"

class Turbo::Replay::Repo::MemoryTest < ActiveSupport::TestCase
  setup do
    @repo =
      Turbo::Replay::Repo::Memory.new

    @retention =
      Turbo::Replay::Retention.new(ttl: 30.minutes, size: 50)
  end

  test "#insert_message - inserts the first message for a broadcasting" do
    content_with_sequence_number =
      insert_message

    assert_equal({sequence_number: 1, content: "content"}, content_with_sequence_number)
  end

  test "#insert_message - inserts multiple messages incrementing sequence number" do
    contents_with_sequence_number =
      10.times.map { insert_message }

    sequence_numbers =
      contents_with_sequence_number.pluck(:sequence_number)

    assert_equal((1..10).to_a, sequence_numbers)
  end

  test "#insert_message - deletes old messages if cache grows over allowed retention size" do
    @retention.size =
      2

    insert_message
    insert_message
    insert_message
    insert_message
    insert_message

    contents_with_sequence_number =
      @repo.get_all_messages(broadcasting: "broadcasting")

    assert_equal(2, contents_with_sequence_number.length)

    sequence_numbers =
      contents_with_sequence_number.pluck(:sequence_number)

    assert_equal([4, 5], sequence_numbers)
  end

  test "#get_current_sequence_number - returns zero if broadcasting does NOT have any message" do
    sequence_number =
      @repo.get_current_sequence_number(broadcasting: "broadcasting")

    assert_equal(0, sequence_number)
  end

  test "#get_current_sequence_number - returns the current sequence number" do
    insert_message
    insert_message

    sequence_number =
      @repo.get_current_sequence_number(broadcasting: "broadcasting")

    assert_equal(2, sequence_number)
  end

  test "#get_all_messages - returns an empty list if broadcasting does NOT have any message" do
    assert_equal [], @repo.get_all_messages(broadcasting: "broadcasting")
  end

  test "#get_all_messages - returns stored messages in the same order they were inserted" do
    insert_message
    insert_message

    contents_with_sequence_number =
      @repo.get_all_messages(broadcasting: "broadcasting")

    sequence_numbers =
      contents_with_sequence_number.pluck(:sequence_number)

    assert_equal([1, 2], sequence_numbers)
  end

  private

  def insert_message
    @repo.insert_message(broadcasting: "broadcasting", content: "content", retention: @retention)
  end
end
