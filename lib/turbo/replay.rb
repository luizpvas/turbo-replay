%w[
  version
  railtie
  engine
  retention
  message
  overrides/streams_channel_broadcast
  overrides/streams_channel_receive
  repo/base
  repo/memory
  repo/redis
].each do |dependency|
  require "turbo/replay/#{dependency}"
end

module Turbo
  module Replay
    include ActiveSupport::Autoload

    class Configuration
      attr_accessor :repo, :retention
    end

    mattr_accessor :configuration
    self.configuration = Configuration.new

    def self.configure
      yield(configuration)
    end
  end
end
