require "redis"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/hash/except"

require "fetcher/fetcher"
require "fetcher/url_memoizer"

require "fetcher/version"

module Fetcher
  def self.update_all
    UrlMemoizer.get_list.each do |url|
      Fetcher.new(url: url).fetch
    end
  end

  def self.redis_connection
  	@redis_connection ||= Redis.new
  end

  def self.redis_connection=(conn)
  	@redis_connection = conn
  end
end
