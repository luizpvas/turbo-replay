require "test_helper"

class FakeChannel
  include Turbo::Replay::Overrides::StreamsChannelReceive

  attr_reader :transmit_called_with

  def params
    {signed_stream_name: "signed_stream_name"}
  end

  def self.verified_stream_name(signed_stream_name)
    signed_stream_name
  end

  def transmit(data)
    @transmit_called_with = data
  end
end

class Turbo::Replay::Overrides::StreamsChannelReceiveTest < ActiveSupport::TestCase
  setup do
    @channel = FakeChannel.new
  end

  test ".received for get_current_sequence_number" do
    @channel.receive({"cmd" => "get_current_sequence_number"})

    assert_equal(
      {get_current_sequence_number: 0},
      @channel.transmit_called_with
    )
  end

  test ".received for get_messages_after_sequence_number" do
    @channel.receive({"cmd" => "get_messages_after_sequence_number", "sequence_number" => 1})

    assert_equal(
      {get_messages_after_sequence_number: []},
      @channel.transmit_called_with
    )
  end

  test ".received for other commands does NOT transmit anything" do
    @channel.receive({"cmd" => "unknown"})

    assert_nil(@channel.transmit_called_with)
  end
end
