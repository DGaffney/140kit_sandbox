# Go to http://wiki.merbivore.com/pages/init-rb
 
# Specify your dependencies in the Gemfile

use_orm :datamapper
use_test :rspec
use_template_engine :erb
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = '485ec41f3d5b27be99ca83598b7b66de209fdf16'  # required for cookie session store
  c[:session_id_key] = '_site_session_id' # cookie session id key, defaults to "_session_id"
end

`ls lib`.split("\n").each do |file|
  require "lib/#{file}" if file.include?(".rb")
end
Merb::BootLoader.before_app_loads do
  require 'rubygems'
  require 'bundler/setup'
  require 'digest/sha1'
  require 'dm-core'
  require 'dm-types'
  require 'dm-aggregates'
  require 'dm-validations'
  require 'dm-migrations'
  require 'dm-migrations/migration_runner'
  require 'dm-chunked_query'
  require 'eventmachine'
  require 'em-http'
  require 'json'
  require 'ntp'
  require 'open-uri'
  require 'twitter'

  DIR = File.dirname(__FILE__).gsub("/config", "")

  require DIR+'/lib/extensions/array'
  require DIR+'/lib/extensions/string'
  require DIR+'/lib/extensions/hash'
  require DIR+'/lib/extensions/fixnum'
  require DIR+'/lib/extensions/float'
  require DIR+'/lib/extensions/time'
  require DIR+'/lib/extensions/nil_class'

  # require DIR+'/lib/extensions/inflectors'

  require DIR+'/lib/utils/git'
  require DIR+'/lib/utils/sh'

  ENV['HOSTNAME'] = Sh::hostname
  ENV['PID'] = Process.pid.to_s #because ENV only allows strings.
  ENV['INSTANCE_ID'] = Digest::SHA1.hexdigest("#{ENV['HOSTNAME']}#{ENV['PID']}")
  ENV['TMP_PATH'] = DIR+"/tmp_files/#{ENV['INSTANCE_ID']}/scratch_processes"
  
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  AnalyticalOffering.all(:language => "ruby", :enabled => true).each do |analytic|
    require DIR+"/lib/tools/#{analytic.function}"    
  end
  # This will get executed after your app's classes have been loaded.
end