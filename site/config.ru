begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

require 'merb-core'

Merb::Config.setup(
  :merb_root   => File.expand_path(File.dirname(__FILE__)),
  :environment => ENV['RACK_ENV']
)

Merb.environment = Merb::Config[:environment]
Merb.root        = Merb::Config[:merb_root]

Merb::BootLoader.run 

run Merb::Rack::Application.new
