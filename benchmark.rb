require "bundler/setup"
require_relative "./test/dummy/config/environment"
require "turbo/replay"
require "benchmark"
require "redis"

RUNS = 20_000

Benchmark.bm do |x|
  memory =
    Turbo::Replay::Repo::Memory.new

  memory_without_synchronization =
    Turbo::Replay::Repo::Memory.new(synchronized: false)

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

  x.report("memory without synchronization") do
    RUNS.times do
      memory_without_synchronization.insert_message(
        broadcasting: "broadcasting",
        content: "<div>This is an event</div>",
        retention: retention
      )
    end
  end

  x.report("redis multiple commands") do
    RUNS.times do
      redis.insert_message(
        broadcasting: "broadcasting",
        content: "<div>This is an event</div>",
        retention: retention
      )
    end
  end

  x.report("redis multi transaction") do
    RUNS.times do
      redis.insert_message_multi(
        broadcasting: "broadcasting",
        content: "<div>This is an event</div>",
        retention: retention
      )
    end
  end

  x.report("redis lua script") do
    RUNS.times do
      redis.insert_message_lua(
        broadcasting: "broadcasting",
        content: "<div>This is an event</div>",
        retention: retention
      )
    end
  end
end
