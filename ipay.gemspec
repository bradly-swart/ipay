# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ipay/version'

Gem::Specification.new do |spec|
  spec.name          = "ipay"
  spec.version       = Ipay::VERSION
  spec.authors       = ["Bradly Swart"]
  spec.email         = ["brad@devmanagementhq.com"]
  spec.summary       = %q{TCP/IP interface to Ipay}
  spec.description   = %q{Low level interface library for integrating with Ipay Bizswitch system for prepaid vending of electricty, airtime and ticketing.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'pry'

  spec.add_dependency 'net_tcp_client'
  spec.add_dependency 'nokogiri'
end
