# Prefetcher
[![Build Status](https://travis-ci.org/brain-geek/prefetcher.svg?branch=master)](https://travis-ci.org/brain-geek/prefetcher)
[![Code Climate](https://codeclimate.com/github/brain-geek/prefetcher/badges/gpa.svg)](https://codeclimate.com/github/brain-geek/prefetcher)
[![Test Coverage](https://codeclimate.com/github/brain-geek/prefetcher/badges/coverage.svg)](https://codeclimate.com/github/brain-geek/prefetcher)

This gem provides a simple-to-use interface to work with frequently requested http data from your api. It gets request response from memory, if possible. But also this means you have to update this cache from time to time (using [whenever](https://github.com/javan/whenever), for example). Any kind of non-200 responses will not be memoized, so you can be always sure that you don't use broken data. Redis is used to store data. [RDoc](http://rdoc.info/github/brain-geek/prefetcher/master/frames)

## Installation

Add this line to your application's Gemfile:

    gem 'prefetcher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prefetcher

You can also override redis connection details (if not using default localhost:6379 ):

    Prefetcher.redis_connection = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 15)

See [redis gem documentation](https://github.com/redis/redis-rb#getting-started) for more options when creating redis connection.
    
## Usage for fetching HTTP requests

### Using cached requests

After installing project you can request any URL:
    
    Prefetcher::Fetcher.new(worker_class: Prefetcher::HttpRequester).get(url: 'http://www.reddit.com/r/ruby')

Calling #get any number of times will return data from cache.

### Force fetch

If you want to force request (and save the response), you can call #force_fetch:

    Prefetcher::Fetcher.new(worker_class: Prefetcher::HttpRequester).force_fetch(url: 'http://www.reddit.com/r/ruby')

This will cause actual http request.

### Updating cache

Calling manualy. You can call *Prefetcher.update_all* to fetch all URLs right now.

You can also automate this call using [whenever](https://github.com/javan/whenever) or other library of your choice. Just add this code to your schedule.rb .

    every 30.minutes do
      runner "Prefetcher.update_all"
    end%

## Contributing

1. Fork it ( https://github.com/brain-geek/prefetcher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
