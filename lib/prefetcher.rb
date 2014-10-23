require "redis"
require 'celluloid'

require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/hash/except"

require "prefetcher/http_requester"
require "prefetcher/http_memoizer"
require "prefetcher/http_fetcher"

require "prefetcher/version"

module Prefetcher
  # Updates all memoized requests
  def self.update_all(options = {})
    HttpMemoizer.new(options).get_list.map do |fetcher|
      fetcher.fetch_async
    end.map(&:value)

    true
  end

  def self.redis_connection
    @redis_connection ||= Redis.new
  end

  def self.redis_connection=(conn)
    @redis_connection = conn
  end
end
