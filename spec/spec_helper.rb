require 'rubygems'
require 'bundler/setup'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'webmock/rspec'
WebMock.disable_net_connect!(:allow => "codeclimate.com")

require 'prefetcher'

Bundler.require

# Disabling old rspec should syntax
RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  
  config.before(:each) do
    Prefetcher.redis_connection = MockRedis.new
  end
end