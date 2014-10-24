require 'spec_helper'

describe Prefetcher::HttpFetcher do
  let(:redis_connection) { MockRedis.new }
  let(:worker_class) { Prefetcher::HttpRequester }
  let(:worker_params) { Hash[url: Faker::Internet.http_url] }

  let(:default_params) { Hash[worker_class: worker_class, redis_connection: redis_connection] }
  let(:params) { default_params }
  let(:object) { described_class.new(params) }

  let(:request_body) { Faker::HTMLIpsum.ul_short }

  describe "#initialize" do
    it "fails if no url given" do
      expect { described_class.new(default_params.except(:url)).to raise_error }
    end
  end

  describe "#fetch" do
    subject { object.fetch(worker_params) }

    describe "when fetcher returns something non-nil" do
      before do
        allow(object.worker_class).to receive_message_chain(:new, :fetch).with(worker_params).with(no_args).and_return request_body
      end

      it "returns data from returned" do
        expect(subject).to eq request_body
      end

      it "saves returned data to url_memoizer" do
        subject
        expect(object.memoizer.get(worker_class, worker_params)).to eq(request_body)
      end
    end

    describe "when fetcher returns nil (something bad happened)" do
      before do
        allow(object.worker_class).to receive_message_chain(:new, :fetch).with(worker_params).with(no_args).and_return nil
      end

      it "returns nil" do
        expect(subject).to be_nil
      end

      it "does not write this to cache" do
        subject
        expect(object.memoizer.get(worker_class, worker_params)).to be_nil
      end
    end

    context "integration - 200" do
      before { stub_request(:get, worker_params[:url]).to_return(:body => request_body) }

      it "gets data from real world http query" do
        expect(subject).to eq request_body
      end
    end

    context "integration - 500" do
      before { stub_request(:get, worker_params[:url]).to_return(body: request_body, status: 500) } 

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe "#get" do
    let(:request_body) { Faker::HTMLIpsum.ul_short.force_encoding('US-ASCII') } # real-world case with encoding
    subject { object.get(worker_params) }

    describe "when no data present in cache" do
      before do
        allow(object.worker_class).to receive_message_chain(:new, :fetch).with(worker_params).with(no_args).and_return request_body
      end

      it "calls #fetch" do
        expect(subject).to eq request_body
      end
    end

    describe "when there is data in cache" do
      before do
        object.memoizer.set(worker_class, worker_params, request_body)
      end

      it "returns data from cache" do
        expect(subject).to eq request_body
      end
    end
  end
end