# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pessimize/version'

Gem::Specification.new do |gem|
  gem.name          = "pessimize"
  gem.version       = Pessimize::VERSION
  gem.authors       = ["Jon Cairns"]
  gem.email         = ["jon@joncairns.com"]
  gem.description   = %q{Add version numbers with the pessimistic constraint operator to all gems in your Gemfile}
  gem.summary       = %q{Add version numbers with the pessimistic constraint operator to all gems in your Gemfile}
  gem.homepage      = ""

  gem.add_development_dependency 'rspec', '~> 2.13.0'
  gem.add_development_dependency 'rake', '~> 10.0.3'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]
end
