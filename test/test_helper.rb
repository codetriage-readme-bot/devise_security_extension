ENV['RAILS_ENV'] ||= 'test'
DEVISE_ORM = (ENV['DEVISE_ORM'] || :active_record).to_sym

$:.unshift File.dirname(__FILE__)

require 'dummy/config/environment'
require 'rails/test_help'
require "orm/#{DEVISE_ORM}"

$:.unshift(File.expand_path(File.dirname(__FILE__) + '../../lib/'))
require 'devise_security_extension'

if ActiveSupport.respond_to?(:test_order)
  ActiveSupport.test_order = :random
end

$:.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
