# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "simplecov"
SimpleCov.start

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"
require "minitest/autorun"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

class ActiveSupport::TestCase
  setup do
    Turbo::Replay.configuration.repo =
      Turbo::Replay::Repo::Memory.new

    Turbo::Replay.configuration.retention =
      Turbo::Replay::Retention.new(ttl: 30.minutes, size: 50)
  end
end
