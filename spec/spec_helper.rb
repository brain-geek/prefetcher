require 'rubygems'
require 'bundler/setup'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'fetcher'

Bundler.require

# Disabling old rspec should syntax
RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  
  config.before(:each) do
    Fetcher.redis_connection = MockRedis.new
  end
end