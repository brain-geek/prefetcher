require 'spec_helper'

describe Prefetcher::HttpMemoizer do

  describe "#initialize" do
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

  describe "#get" do
    let(:memoizer) { described_class.new }
    let(:key) { Faker::Internet.http_url }
    subject { memoizer.get(key) }

    it "returns nil when no such key present" do
      expect(subject).to be_nil
    end

    it "returns value from the latest set call" do
      memoizer.set key, 'asdf'
      memoizer.set key, 'asd'

      expect(subject).to eq 'asd'
    end
  end

  describe "#get_list" do
    let(:memoizer) { described_class.new }
    let(:url) { Faker::Internet.http_url }
    subject { memoizer.get_list }

    it "returns empty array by default" do
      expect(subject).to be_empty
    end

    it "returns the url once, even if it was memorized multiple times" do
      memoizer.set url, 'asd'
      memoizer.set url, 'asd'

      expect(subject.length).to eq(1)
      target = subject.first

      expect(target).to be_a_kind_of Prefetcher::HttpFetcher
      expect(target.url).to eq url
      expect(target.memoizer).to be(memoizer)
    end

    it "returns all given urls" do
      urls = 3.times.map { Faker::Internet.http_url }

      urls.each do |url|
        memoizer.set url, 'asd'
      end

      expect(subject.map(&:url).sort).to eq urls.sort
    end
  end
end