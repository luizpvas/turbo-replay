require "test_helper"

class Turbo::Replay::VersionTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert_equal("0.1.2", Turbo::Replay::VERSION)
  end
end
