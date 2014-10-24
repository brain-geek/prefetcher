require 'spec_helper'

describe Prefetcher do
  describe "redis connection accessors" do
    it "returns previously set connection" do
      described_class.redis_connection = (conn = double("Redis"))

      expect(described_class.redis_connection).to eq conn
    end

    it "uses Redis.new without arguments by default" do
      expect(Redis).to receive(:new).with(no_args).and_return(conn = double("Redis"))

      expect(described_class.redis_connection).to_not eq conn

      described_class.redis_connection = nil

      expect(described_class.redis_connection).to eq conn
    end
  end

  describe "::update_all" do
    let(:url) { Faker::Internet.http_url }
    before do
      Prefetcher.redis_connection = Redis.new
      Prefetcher::Memoizer.new.clear_list
    end

    it "should update data in Fetcher fetched URLs" do
        stub_request(:get, url).to_return(
                      {:body => "1", :status => ["200", "OK"]},
                      {:body => "2", :status => ["200", "OK"]})

        obj = Prefetcher::Fetcher.new(worker_class: Prefetcher::HttpRequester)

        expect(obj.get(url: url)).to eq "1"
        expect(obj.get(url: url)).to eq "1"

        described_class.update_all

        expect(obj.get(url: url)).to eq "2"
    end
  end

  describe "integration" do
    let(:url) { Faker::Internet.http_url }
    before do
      Prefetcher.redis_connection = Redis.new
      Prefetcher::Memoizer.new.clear_list
    end

    it "should work within workflow with real Redis" do
        stub_request(:get, url).to_return(
                      {:body => "1", :status => ["200", "OK"]},
                      {:body => "2", :status => ["200", "OK"]},
                      {:body => "3", :status => ["200", "OK"]})

        obj = Prefetcher::Fetcher.new(worker_class: Prefetcher::HttpRequester)

        expect(obj.get(url: url)).to eq "1"
        expect(obj.get(url: url)).to eq "1"

        obj.force_fetch(url: url)

        expect(obj.get(url: url)).to eq "2"

        obj = Prefetcher::Fetcher.new(worker_class: Prefetcher::HttpRequester)

        Prefetcher.update_all

        expect(obj.get(url: url)).to eq "3"
    end
  end
end
