module Prefetcher
  class HttpMemoizer
    attr_accessor :redis_connection

    def initialize(params = {})
      self.redis_connection = params.fetch(:redis_connection, Prefetcher.redis_connection)
    end

    # Save and add URL to memoized list
    def set(url, value)
      redis_connection.set(url, value)
      redis_connection.sadd(items_list, url)
    end

    def get(url)
      redis_connection.get(url)
    end

    # Get all memoized URLs
    def get_list
      redis_connection.smembers items_list
    end

    protected 
    def cache_key(url)
      "cached-url-#{url}"
    end

    def items_list
      "urls-list"
    end
  end
end