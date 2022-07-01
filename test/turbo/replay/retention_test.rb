require "test_helper"

class Turbo::Replay::RetentionTest < ActiveSupport::TestCase
  test "has attributes for ttl and size" do
    value = Turbo::Replay::Retention.new(ttl: 30.minutes, size: 50)

    assert_equal 30.minutes, value.ttl
    assert_equal 50, value.size
  end
end
