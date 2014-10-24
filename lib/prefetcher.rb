require "redis"
require "thread/pool"

require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/hash/except"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/string/inflections"

require "prefetcher/memoizer"
require "prefetcher/fetcher"

require "prefetcher/base_requester"
require "prefetcher/http_requester"

require "prefetcher/version"

module Prefetcher
  # Updates all memoized requests
  def self.update_all(options = {})
    Memoizer.new(options).get_list.map do |data_source, arguments|
      pool = Thread.pool(8)

      arguments.map do |arg_set|
        pool.process {
          fetcher = Fetcher.new(data_source: data_source).force_fetch(arg_set)
        }
      end

      pool.shutdown
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
