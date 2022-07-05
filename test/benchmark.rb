require "bundler/setup"
require_relative "./dummy/config/environment"
require "turbo/replay"
require "benchmark"
require "redis"

RUNS = 20_000

Benchmark.bm do |x|
  memory =
    Turbo::Replay::Repo::Memory.new

  redis =
    Turbo::Replay::Repo::Redis.new(client: Redis.new)

  retention =
    Turbo::Replay::Retention.new(ttl: 30.minutes, size: 50)

  x.report("memory") do
    RUNS.times do
      memory.insert_message(
        broadcasting: "broadcasting",
        content: "<div>This is an event</div>",
        retention: retention
      )
    end
  end

  x.report("redis") do
    RUNS.times do
      redis.insert_message(
        broadcasting: "broadcasting",
        content: "<div>This is an event</div>",
        retention: retention
      )
    end
  end
end
