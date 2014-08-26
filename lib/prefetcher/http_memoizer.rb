module Prefetcher
  class HttpMemoizer
    attr_reader :redis_connection

    def initialize(params = {})
      @redis_connection = params.fetch(:redis_connection, Prefetcher.redis_connection)
    end

    # Add URL to memoized list
    def push(url)
      redis.sadd(cache_key, url)
    end

    # Get all memoized URLs
    def get_list
      redis.smembers cache_key
    end

    protected 
    def cache_key
      "urls-list"
    end

    def redis
      Prefetcher.redis_connection
    end
  end
end