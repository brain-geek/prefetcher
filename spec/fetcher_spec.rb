require 'spec_helper'

describe Fetcher do
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

    it "should update data in HttpFetcher fetched URLs" do
        FakeWeb.register_uri(:get, url,
                     [{:body => "1", :status => ["200", "OK"]},
                      {:body => "2", :status => ["200", "OK"]}])

        obj = Fetcher::HttpFetcher.new(url: url)

        expect(obj.get).to eq "1"
        expect(obj.get).to eq "1"

        Fetcher.update_all

        expect(obj.get).to eq "2"
    end
  end
end
