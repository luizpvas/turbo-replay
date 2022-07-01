require "test_helper"

class Turbo::Replay::ConfigurationTest < ActiveSupport::TestCase
  test "has a single configuration" do
    Turbo::Replay.configure do |config|
      assert config.is_a?(Turbo::Replay::Configuration)
    end
  end

  test "has retention attribute" do
    retention = Turbo::Replay::Retention.new(ttl: 30.minutes, size: 50)

    Turbo::Replay::Configuration.new.tap do |config|
      config.retention = retention
      assert_equal config.retention, retention
    end
  end
end
