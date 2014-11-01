require 'ipay'
require_relative '../lib/ipay/IpayRequest'
require 'factory_girl'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
   config.tty = true

 # Use the specified formatter
   config.formatter = :documentation # :progress, :html, :textmate
   config.include FactoryGirl::Syntax::Methods
end
