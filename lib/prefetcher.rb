require "redis"
require 'celluloid'

require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/hash/except"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/string/inflections"

require "prefetcher/memoizer"
require "prefetcher/http_requester"
require "prefetcher/fetcher"

require "prefetcher/version"

module Prefetcher
  # Updates all memoized requests
  def self.update_all(options = {})
    
    Memoizer.new(options).get_list.map do |worker_class, arguments|
      pool = Fetcher.pool(args: [worker_class: worker_class])

      arguments.map do |arg_set|
        pool.async.fetch(arg_set)
      end

      unless pool.idle_size == pool.size
        sleep 0.0001
      end
    end

    true
  end

  def self.redis_connection
    @redis_connection ||= Redis.new
  end

  def self.redis_connection=(conn)
    @redis_connection = conn
  end
end
