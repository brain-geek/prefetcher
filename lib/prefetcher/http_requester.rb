module Prefetcher
  class HttpRequester
    attr_accessor :url

    def initialize(hash = {})
      self.url = hash.fetch(:url, false) || hash.fetch('url')
    end

    def fetch
      uri = URI(URI.encode(url))
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      if response.code == "200"
        response.body
      else
        nil
      end
    end

    def to_params
      Hash[url: url]
    end
  end
end