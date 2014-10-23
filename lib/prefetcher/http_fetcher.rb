module Prefetcher
  class HttpFetcher
    attr_reader :url, :memoizer

    def initialize(params = {})
      @url = params.fetch(:url)
      @memoizer = params.fetch(:memoizer, HttpMemoizer.new)
    end

    # Makes request to given URL
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

    # Returns cached version if availible. If not cached - makes request using #fetch .
    def get
      (get_from_memory || fetch).html_safe.force_encoding('utf-8')
    end

    protected
    def get_from_memory
      memoizer.get(url)
    end

    def memoize(response)
      memoizer.set(url, response)
    end
  end
end