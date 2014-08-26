require "redis"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/hash/except"

require "prefetcher/http_fetcher"
require "prefetcher/http_memoizer"

require "prefetcher/version"

module Prefetcher
  def self.update_all(options = {})
    HttpMemoizer.new(options).get_list.each do |url|
      HttpFetcher.new(options.merge(url: url)).fetch
    end
  end

  def self.redis_connection
    @redis_connection ||= Redis.new
  end

  def self.redis_connection=(conn)
    @redis_connection = conn
  end
end
