module Prefetcher
  class BaseRequester
    attr_accessor :attributes

    def initialize(attrs = {})
      self.attributes = attrs.with_indifferent_access
    end
  end
end
