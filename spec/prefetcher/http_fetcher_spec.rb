require 'spec_helper'

describe Prefetcher::HttpFetcher do
  let(:redis_connection) { MockRedis.new }

  let(:default_params) { Hash[url: url, redis_connection: redis_connection] }
  let(:params) { default_params }
  let(:object) { described_class.new(params) }

  let(:url) { Faker::Internet.http_url }
  let(:request_body) { Faker::HTMLIpsum.ul_short }

  describe "#initialize" do
    it "fails if no url given" do
      expect { described_class.new(default_params.except(:url)).to raise_error }
    end
  end

  describe "#fetch" do
    subject { object.fetch }

    describe "200 response" do
      before { stub_request(:get, url).to_return(:body => request_body) }

      it "gets data from real world http query" do
        expect(subject).to eq request_body
      end

      it "makes http requests the same number of times as called" do
        stub_request(:get, url).to_return(
                      {:body => "1", :status => ["200", "OK"]},
                      {:body => "2", :status => ["200", "OK"]},
                      {:body => "3", :status => ["200", "OK"]})

        expect(object.fetch).to eq "1"
        expect(object.fetch).to eq "2"
        expect(object.fetch).to eq "3"
        expect(object.fetch).to eq "3" # fakeweb feature - when no more responces, it uses last
      end

      it "saves given url to url_memoizer" do
        expect(object.memoizer).to receive(:set).with(url, request_body)
        subject
      end
    end

    describe "500 response" do
      before do
        stub_request(:get, url).to_return(body: request_body, status: 500)
      end

      it "returns empty string" do
        expect(subject).to be_empty
      end

      it "does not write this to cache" do
        subject
        expect(redis_connection.get("cached-url-#{url}")).to be_nil
      end
    end

    describe "404 response" do
      before do
        stub_request(:get, url).to_return(body: request_body, status: 404)
      end

      it "returns empty string" do
        expect(subject).to be_empty
      end

      it "does not write this to cache" do
        subject
        expect(redis_connection.get("cached-url-#{url}")).to be_nil
      end
    end
  end

  describe "#get" do
    let(:request_body) { Faker::HTMLIpsum.ul_short.force_encoding('US-ASCII') } # real-world case with encoding
    subject { object.get }

    describe "when no data already present in cache" do
      before { expect(object).to receive(:fetch).and_return(request_body) }

      it "calls #fetch" do
        expect(subject).to eq request_body
      end

      it "returns html safe value" do
        expect(subject).to be_html_safe
      end

      it "returns utf-8 encoded string" do
        expect(subject.encoding.to_s).to eq "UTF-8"
      end
    end

    describe "when there is data in cache" do
      before do
        expect(object).to_not receive(:fetch)
        object.memoizer.set(url, request_body)
      end

      it "returns data only from cache" do
        expect(subject).to eq request_body
      end

      it "returns html safe value" do
        expect(subject).to be_html_safe
      end

      it "returns utf-8 encoded string" do
        expect(subject.encoding.to_s).to eq "UTF-8"
      end
    end
  end
end