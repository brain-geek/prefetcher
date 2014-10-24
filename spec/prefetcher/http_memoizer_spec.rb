require 'spec_helper'

describe Prefetcher::HttpMemoizer do

  describe "#initialize" do
    context "redis connection" do
      it "uses default connection if not set explicitly" do
        Prefetcher.redis_connection = (connection = double('Redis'))
        object = described_class.new

        expect(object.redis_connection).to be connection
      end

      it "uses passed redis connection if received" do
        Prefetcher.redis_connection = (other_connection = double('Redis'))
        connection = double('Redis')

        object = described_class.new(redis_connection: connection)
        expect(object.redis_connection).to be connection
      end
    end
  end

  let(:memoizer) { described_class.new }
  let(:worker_class) { Prefetcher::HttpRequester }
  let(:params) { Hash["url" => Faker::Internet.http_url] }

  describe "#get" do
    subject { memoizer.get(worker_class, params) }

    it "returns nil when no such key present" do
      expect(subject).to be_nil
    end

    it "returns value from the latest set call" do
      memoizer.set worker_class, params, 'asdf'
      memoizer.set worker_class, params, 'asd'

      expect(subject).to eq 'asd'
    end
  end

  describe "#get_list" do
    subject { memoizer.get_list }

    it "returns empty array by default" do
      expect(subject).to be_empty
    end

    it "returns the key once, even if it was memorized multiple times" do
      memoizer.set worker_class, params, 'asdd'
      memoizer.set worker_class, params, 'asd'

      expect(subject).to eq(Hash[worker_class => [ params ]])
    end

    it "returns the same key even if hash is different (strings <-> symbols)" do
      memoizer.set worker_class, Hash[url: params['url']], 'asd'

      expect(subject).to eq(Hash[worker_class => [ params ]])
    end

    it "returns all given urls" do
      urls = 3.times.map { Faker::Internet.http_url }

      urls.each do |url|
        memoizer.set worker_class, {"url" =>  url}, 'asd'
      end

      expect(subject[worker_class]).to match_array(urls.map{|url| Hash["url" => url]})
    end

    it "#clear_list" do
      urls = 3.times.map { Faker::Internet.http_url }

      urls.each do |url|
        memoizer.set worker_class, {"url" =>  url}, 'asd'
      end

      memoizer.clear_list

      expect(subject).to be_empty
    end
  end
end