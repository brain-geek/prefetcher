module Prefetcher
  class Fetcher
    include Celluloid
    attr_reader :memoizer, :data_source

    def initialize(params = {})
      @memoizer = params.fetch(:memoizer, Memoizer.new)
      @data_source = params.fetch(:data_source)
    end

    def force_fetch(params)
      params = params.with_indifferent_access

      result = data_source.new(params).fetch
      memoize(params, result) unless result.nil?
      result
    end

    # Returns cached version if availible. If not cached - makes request using #fetch .
    def get(params)
      params = params.with_indifferent_access

      get_from_memory(params) || force_fetch(params)
    end

    protected
    
    def get_from_memory(params)
      params = params.with_indifferent_access

      memoizer.get(data_source, params)
    end

    def memoize(params, result)
      memoizer.set(data_source, params, result)
    end
  end
end