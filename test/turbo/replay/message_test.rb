require "test_helper"

class Turbo::Replay::MessageTest < ActiveSupport::TestCase
  setup do
    Turbo::Replay.configure do |config|
      @fake_repo = Minitest::Mock.new

      config.repo = @fake_repo
    end
  end

  test ".get_current_sequence_number - calls the repo with the correct input" do
    @fake_repo.expect(:get_current_sequence_number, nil, broadcasting: "broadcasting")

    Turbo::Replay::Message.get_current_sequence_number(broadcasting: "broadcasting")

    assert_mock(@fake_repo)
  end

  test ".get_current_sequence_number - returns the value returned from the repo" do
    @fake_repo.expect(:get_current_sequence_number, 2, broadcasting: "broadcasting")

    sequence_number =
      Turbo::Replay::Message.get_current_sequence_number(broadcasting: "broadcasting")

    assert_equal(2, sequence_number)
  end

  test ".get_after_sequence_number - filters out messages before the sequence number" do
    expected_arguments =
      {broadcasting: "broadcasting"}

    return_value =
      [
        {sequence_number: 10, content: "content_10"},
        {sequence_number: 11, content: "content_11"},
        {sequence_number: 12, content: "content_12"}
      ]

    @fake_repo.expect(:get_all_messages, return_value, **expected_arguments)

    contents_with_sequence_number =
      Turbo::Replay::Message.get_after_sequence_number(broadcasting: "broadcasting", sequence_number: 11)

    assert_equal(
      [{sequence_number: 12, content: "content_12"}],
      contents_with_sequence_number
    )

    assert_mock(@fake_repo)
  end

  test ".get_after_sequence_number - returns all messages if the sequence_number is exactly one less than the oldest" do
    expected_arguments =
      {broadcasting: "broadcasting"}

    return_value =
      [
        {sequence_number: 10, content: "content_10"},
        {sequence_number: 11, content: "content_11"},
        {sequence_number: 12, content: "content_12"}
      ]

    @fake_repo.expect(:get_all_messages, return_value, **expected_arguments)

    contents_with_sequence_number =
      Turbo::Replay::Message.get_after_sequence_number(broadcasting: "broadcasting", sequence_number: 9)

    assert_equal(return_value, contents_with_sequence_number)
    assert_mock(@fake_repo)
  end

  test ".get_after_sequence_number - returns :unrecoverable if sequence_number is less than the ooldest message" do
    expected_arguments =
      {broadcasting: "broadcasting"}

    return_value =
      [
        {sequence_number: 10, content: "content_10"},
        {sequence_number: 11, content: "content_11"},
        {sequence_number: 12, content: "content_12"}
      ]

    @fake_repo.expect(:get_all_messages, return_value, **expected_arguments)

    contents_with_sequence_number =
      Turbo::Replay::Message.get_after_sequence_number(broadcasting: "broadcasting", sequence_number: 8)

    assert_equal(:unrecoverable, contents_with_sequence_number)
    assert_mock(@fake_repo)
  end

  test ".get_after_sequence_number - sorts the return value from the repository" do
    expected_arguments =
      {broadcasting: "broadcasting"}

    return_value =
      [
        {sequence_number: 12, content: "content_12"},
        {sequence_number: 10, content: "content_10"},
        {sequence_number: 11, content: "content_11"}
      ]

    @fake_repo.expect(:get_all_messages, return_value, **expected_arguments)

    contents_with_sequence_number =
      Turbo::Replay::Message.get_after_sequence_number(broadcasting: "broadcasting", sequence_number: 10)

    assert_equal(
      [
        {sequence_number: 11, content: "content_11"},
        {sequence_number: 12, content: "content_12"}
      ],
      contents_with_sequence_number
    )

    assert_mock(@fake_repo)
  end

  test ".get_after_sequence_number - returns an empty list if sequence number is nil" do
    contents_with_sequence_number =
      Turbo::Replay::Message.get_after_sequence_number(broadcasting: "broadcasting", sequence_number: nil)

    assert_equal([], contents_with_sequence_number)
  end

  test ".insert - calls the repo with the correct input and returns the same value" do
    retention =
      Turbo::Replay.configuration.retention

    expected_arguments =
      {broadcasting: "broadcasting", content: "content", retention: retention}

    return_value =
      {sequence_number: 1, content: "content"}

    @fake_repo.expect(:insert_message, return_value, **expected_arguments)

    assert_equal(
      return_value,
      Turbo::Replay::Message.insert(broadcasting: "broadcasting", content: "content")
    )

    assert_mock(@fake_repo)
  end
end
