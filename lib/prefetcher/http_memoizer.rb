module Prefetcher
  class HttpMemoizer
    attr_accessor :redis_connection

    def initialize(params = {})
      self.redis_connection = params.fetch(:redis_connection, Prefetcher.redis_connection)
    end

    # Save and add URL to memoized list
    def set(worker_class, params, value)
      redis_connection.set(cache_key(worker_class, params), value)

      redis_connection.sadd(worker_classes_list, worker_class.to_s)
      redis_connection.sadd(items_list(worker_class), JSON.dump(params))
    end

    def get(worker_class, params)
      redis_connection.get(cache_key(worker_class, params))
    end

    # Get all memoized URLs
    def get_list
      result = Hash.new

      redis_connection.smembers(worker_classes_list).each do |worker_class|
        worker_class = Object.const_get(worker_class)

        result[worker_class] = redis_connection.smembers(items_list(worker_class)).map do |params|
          JSON.parse(params)
        end
      end

      result
    end

    def clear_list
      redis_connection.smembers(worker_classes_list).each do |worker_class|
        redis_connection.del(items_list(worker_class))
      end

      redis_connection.del(worker_classes_list)
    end

    protected 
    def cache_key(worker_class, params)
      params = params.with_indifferent_access

      "cached-url-#{params}-#{worker_class.to_s}"
    end

    def items_list(worker_class)
      "urls-list-#{worker_class}"
    end

    def worker_classes_list
      "workers-list"
    end
  end
end