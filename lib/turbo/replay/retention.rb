module Turbo::Replay
  Retention = Struct.new(:ttl, :size, keyword_init: true)
end 
