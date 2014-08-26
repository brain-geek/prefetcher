# Fetcher
[![Build Status](https://travis-ci.org/brain-geek/fetcher.svg?branch=master)](https://travis-ci.org/brain-geek/fetcher)
[![Code Climate](https://codeclimate.com/github/brain-geek/fetcher/badges/gpa.svg)](https://codeclimate.com/github/brain-geek/fetcher)
[![Test Coverage](https://codeclimate.com/github/brain-geek/fetcher/badges/coverage.svg)](https://codeclimate.com/github/brain-geek/fetcher)

This gem provides a simple-to-use interface to work with frequently requested http requests from your api. It gets request response from memory, if possible. But also this means you have to update this cache from time to time (using [whenever](https://github.com/javan/whenever), for example). Any kind of non-200 responses will not be memoized, so you can be always sure that you don't use broken data.

## Installation

Add this line to your application's Gemfile:

    gem 'fetcher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fetcher

You can also override redis connection details (if not using default localhost:6379 ):
	
	Fetcher.redis_connection = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 15)

See [redis gem documentation](https://github.com/redis/redis-rb#getting-started) for more options when creating redis connection.
	
## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/brain-geek/fetcher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
