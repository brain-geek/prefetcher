require 'spec_helper'

describe Prefetcher do
  describe "integration" do
    before do
      Prefetcher.redis_connection = Redis.new
      Prefetcher::Memoizer.new.clear_list
    end

    class TestDataSource < Prefetcher::BaseRequester
      def fetch
        @@counter ||= 0
        @@counter += 1

        Hash[
          'value' => @@counter,
          'nested' => 'hash',
          'array' => [1,2,3,4]
        ]
      end
    end

    it "should work within workflow with real Redis" do
        obj = Prefetcher::Fetcher.new(data_source: TestDataSource)

        expect(obj.get).to eq Hash[
          'nested' => 'hash',
          'array' => [1,2,3,4],
          'value' => 1
        ]

        expect(obj.get).to eq Hash[
          'nested' => 'hash',
          'array' => [1,2,3,4],
          'value' => 1
        ]

        expect(obj.force_fetch).to eq Hash[
          'nested' => 'hash',
          'array' => [1,2,3,4],
          'value' => 2
        ]

        Prefetcher.update_all

        expect(obj.get).to eq Hash[
          'nested' => 'hash',
          'array' => [1,2,3,4],
          'value' => 3
        ]
    end
  end
end