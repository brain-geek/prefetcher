module Prefetcher
  class Fetcher
    include Celluloid
    attr_reader :memoizer, :worker_class

    def initialize(params = {})
      @memoizer = params.fetch(:memoizer, Memoizer.new)
      @worker_class = params.fetch(:worker_class, HttpRequester)
    end

    def fetch(params)
      params = params.with_indifferent_access

      result = worker_class.new(params).fetch
      memoize(params, result) unless result.nil?
      result
    end

    # Returns cached version if availible. If not cached - makes request using #fetch .
    def get(params)
      params = params.with_indifferent_access

      get_from_memory(params) || fetch(params)
    end

    protected
    
    def get_from_memory(params)
      params = params.with_indifferent_access

      memoizer.get(worker_class, params)
    end

    def memoize(params, result)
      memoizer.set(worker_class, params, result)
    end
  end
end