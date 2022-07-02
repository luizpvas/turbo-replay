require_relative "lib/turbo/replay/version"

Gem::Specification.new do |spec|
  spec.name = "turbo-replay"
  spec.version = Turbo::Replay::VERSION
  spec.authors = ["Luiz Vasconcellos"]
  spec.email = ["luizpvasc@gmail.com"]
  spec.homepage = "https://github.com/luizpvas/turbo-replay"
  spec.summary = "Never miss a single websocket event ever again."
  spec.description = "Turbo-Replay caches events sent to channels and re-sends them in order when clients have flaky network."
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/luizpvas/turbo-replay"
  spec.metadata["changelog_uri"] = "https://github.com/luizpvas/turbo-replay"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "turbo-rails", ">= 0.5"

  spec.add_development_dependency "standard"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "redis"
end
