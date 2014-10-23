module Prefetcher
  class HttpFetcher
    attr_reader :url, :memoizer

    def initialize(params = {})
      @url = params.fetch(:url)
      @memoizer = params.fetch(:memoizer, HttpMemoizer.new)
    end

    # Makes request to given URL in async way
    def fetch_async(worker = HttpRequester.new)
      worker.future(:fetch, url, memoizer)
    end

    def fetch
      fetch_async.value
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