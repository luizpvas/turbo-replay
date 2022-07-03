require "test_helper"

class Turbo::Replay::VersionTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert_equal("0.1.1", Turbo::Replay::VERSION)
  end
end
