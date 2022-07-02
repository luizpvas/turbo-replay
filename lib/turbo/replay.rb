require "turbo/replay/version"
require "turbo/replay/railtie"

require_relative "./replay/retention"
require_relative "./replay/message"
require_relative "./replay/repo/base"
require_relative "./replay/repo/memory"
require_relative "./replay/repo/redis"

module Turbo
  module Replay
    include ActiveSupport::Autoload

    class Configuration
      attr_accessor :repo, :retention
    end

    mattr_accessor :configuration
    self.configuration = Configuration.new

    def self.configure = yield(configuration)
  end
end
