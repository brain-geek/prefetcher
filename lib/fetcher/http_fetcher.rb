module Fetcher
  class HttpFetcher
    attr_reader :url, :redis_connection, :memoizer

    def initialize(params = {})
      @url = params.fetch(:url)
      @redis_connection = params.fetch(:redis_connection, Fetcher.redis_connection)
      @memoizer = params.fetch(:memoizer, HttpMemoizer.new(redis_connection: @redis_connection))
    end

    def fetch
      uri = URI(URI.encode(self.url))

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      if response.code == "200"
        memoize(response.body)
        response.body
      else
        ''
      end
    end

    def get
      (get_from_memory || fetch).html_safe.force_encoding('utf-8')
    end

    protected
    def cache_key
      "cached-url-#{url}"
    end

    def get_from_memory
      @redis_connection.get(cache_key)
    end

    def memoize(response)
      memoizer.push(url)
      @redis_connection.set(cache_key, response)
    end
  end
end