# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pessimize/version'

Gem::Specification.new do |gem|
  gem.name          = "pessimize"
  gem.version       = Pessimize::VERSION
  gem.authors       = ["Jon Cairns"]
  gem.email         = ["jon@joncairns.com"]
  gem.description   = %q{Add the pessimistic constraint operator to all gems in your Gemfile, restricting the maximum update version.

This is for people who work with projects that use bundler, such as rails projects. The pessimistic constraint operator (~>) allows you to specify the maximum version that a gem can be updated, and reduces potential breakages when running `bundle update`. Pessimize automatically retrieves the current versions of your gems, then adds them to your Gemfile (so you don't have to do it by hand).}
  gem.summary       = %q{Add the pessimistic constraint operator to all gems in your Gemfile, restricting the maximum update version.}
  gem.homepage      = "https://github.com/joonty/pessimize"

  gem.add_dependency 'bundler'
  gem.add_dependency 'optimist'
  gem.add_development_dependency 'rspec', '~> 2.13.0'
  gem.add_development_dependency 'rake', '~> 10.0.3'
  gem.add_development_dependency 'codeclimate-test-reporter', '~> 0.6.0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'
end
