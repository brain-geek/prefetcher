module Fetcher
  class UrlMemoizer
    attr_reader :redis_connection

    def initialize(params = {})
      @redis_connection = params.fetch(:redis_connection, ::Fetcher.redis_connection)
    end

    def push(url)
      redis.sadd(cache_key, url)
    end

    def get_list
      redis.smembers cache_key
    end

    protected 
    def cache_key
      "urls-list"
    end

    def redis
      ::Fetcher.redis_connection
    end
  end
end