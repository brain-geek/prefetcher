module Prefetcher
  class HttpRequester
    include Celluloid

    def initialize(url, memoizer)
      @url = url
      @memoizer = memoizer
    end

    def fetch
      uri = URI(URI.encode(@url))
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      response_body = if response.code == "200"
        body = response.body

        @memoizer.set(@url, body)
        body
      else
        ''
      end

      response_body
    end
  end
end