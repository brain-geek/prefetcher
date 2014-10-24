require 'spec_helper'

describe Prefetcher::HttpRequester do
  let(:url) { Faker::Internet.http_url }
  let(:request_body) { Faker::HTMLIpsum.ul_short }

  let(:object) { described_class.new(url: url) }

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
        expect(object.fetch).to eq "3" # fakeweb feature - when no more responses, it uses last
      end
    end

    describe "500 response" do
      before do
        stub_request(:get, url).to_return(body: request_body, status: 500)
      end

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    describe "404 response" do
      before do
        stub_request(:get, url).to_return(body: request_body, status: 404)
      end

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe "#to_params" do
    subject { object.to_params }

    it "returns the set of parameters received in ::new" do
      expect(subject).to eq(url: url)
    end

    describe "when url parameter is received as string key in hash" do
      let(:object) { described_class.new('url' => url) }

      it "returns the set of parameters received in ::new" do
        expect(subject).to eq(url: url)
      end
    end
  end
end