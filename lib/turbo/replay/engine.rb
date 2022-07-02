require "rails/engine"

module Turbo::Replay
  class Engine < ::Rails::Engine
    isolate_namespace Turbo::Replay

    initializer "turbo-replay.overrides" do
      Turbo::StreamsChannel.class # eager load

      class Turbo::StreamsChannel
        extend Overrides::StreamsChannelBroadcast
        prepend Overrides::StreamsChannelReceived
      end
    end
  end
end
