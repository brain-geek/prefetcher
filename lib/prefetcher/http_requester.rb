module Prefetcher
  class HttpRequester < BaseRequester
    def url
      @url ||= (attributes.fetch(:url, false) || attributes.fetch('url'))
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
  end
end