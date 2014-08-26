require 'spec_helper'

describe Fetcher::HttpMemoizer do
  describe "#get_list" do
    let(:memoizer) { described_class.new }
    subject { memoizer.get_list }

    it "returns empty array by default" do
      expect(subject).to be_empty
    end

    it "returns the url once, even if it was memorized multiple times" do
      memoizer.push 'http://noslowpokes.com'
      memoizer.push 'http://noslowpokes.com'

      expect(subject).to eq ['http://noslowpokes.com']
    end

    it "returns all given urls" do
      urls = 3.times.map { Faker::Internet.http_url }

      urls.each do |url|
        memoizer.push url
      end

      expect(subject.sort).to eq urls.sort
    end
  end
end