# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fetcher/version'

Gem::Specification.new do |spec|
  spec.name          = "fetcher"
  spec.version       = Fetcher::VERSION
  spec.authors       = ["Alex Rozumiy"]
  spec.email         = ["brain-geek@yandex.ua"]
  spec.summary       = %q{Prefetching/caching tool for external requests}
  spec.description   = %q{This gem provides possibility to have 'fresh' prefetched result of external http request all the time}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
