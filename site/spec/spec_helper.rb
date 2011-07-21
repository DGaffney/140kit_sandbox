begin
  # Just in case the bundle was locked
  # This shouldn't happen in a dev environment but lets be safe
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

require "spec" # Satisfies Autotest and anyone else not using the Rake tasks
require "merb-core"

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  # You don't need this if you don't use Webrat directly in your specs
  config.include(Merb::Test::WebratHelper)
  
  config.before(:all) do
    DataMapper.auto_migrate! if Merb.orm == :datamapper
  end
  
end
