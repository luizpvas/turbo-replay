require "turbo/replay/version"
require "turbo/replay/railtie"

require_relative "./replay/retention"

module Turbo
  module Replay
    include ActiveSupport::Autoload

    class Configuration
      attr_accessor :retention
    end

    mattr_accessor :configuration
    self.configuration = Configuration.new

    def self.configure = yield(configuration)
  end
end
