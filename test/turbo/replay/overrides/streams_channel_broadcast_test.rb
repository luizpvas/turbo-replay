require "test_helper"

class Turbo::Replay::Overrides::StreamsChannelBroadcastTest < ActiveSupport::TestCase
  test ".broadcast_stream_to - calls the broadcast method in server with the correct input" do
    fake_server =
      Minitest::Mock.new

    expected_args =
      ["broadcasting", {sequence_number: 1, content: "content"}]

    return_value =
      nil

    fake_server.expect(:broadcast, return_value, expected_args)

    ActionCable.stub :server, fake_server do
      Turbo::StreamsChannel.broadcast_stream_to("broadcasting", content: "content")
    end

    assert_mock(fake_server)
  end
end
