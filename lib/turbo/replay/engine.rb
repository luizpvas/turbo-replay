require "rails/engine"

module Turbo::Replay
  class Engine < ::Rails::Engine
    isolate_namespace Turbo::Replay

    initializer "turbo-replay.overrides" do
      class Turbo::StreamsChannel
        extend Overrides::StreamsChannelBroadcast
        prepend Overrides::StreamsChannelReceived
      end
    end
  end
end
