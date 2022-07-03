say "Installing Javascript library"
run "yarn add turbo-replay"

say "Creating initializer"

initializer "turbo_replay.rb", <<-CODE
  require 'turbo/replay'

  Turbo::Replay.configure do |config|
    redis_client = Redis.new(
      host: ENV['REDIS_HOST'],
      port: ENV['REDIS_PORT']
    )

    # Store for broadcasted messages
    config.repo = Turbo::Replay::Repo::Redis.new(client: redis_client)

    # Retention policy
    config.retention = Turbo::Replay::Retention.new(ttl: 60.minutes, size: 50)
  end
CODE
