require "rails/engine"
require "turbo-rails"

module Turbo::Replay
  class Engine < ::Rails::Engine
    isolate_namespace Turbo::Replay

    initializer "turbo-replay.overrides" do
      Turbo::StreamsChannel.tap do |channel|
        channel.extend(Overrides::StreamsChannelBroadcast)
        channel.include(Overrides::StreamsChannelReceive)
      end
    end
  end
end
