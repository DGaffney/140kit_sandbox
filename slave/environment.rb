#note: Changing the order of some of these requires may screw things up. 
#Don't do it if you're not sure.

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

DIR = Dir::pwd

require DIR+'/extensions/dm-extensions'
require DIR+'/extensions/array'
require DIR+'/extensions/string'
require DIR+'/extensions/hash'
require DIR+'/extensions/fixnum'
require DIR+'/extensions/time'
require DIR+'/extensions/nil_class'
require DIR+'/extensions/inflectors'

require DIR+'/utils/git'
require DIR+'/utils/sh'

ENV['HOSTNAME'] = Sh::hostname
ENV['PID'] = Process.pid.to_s #because ENV only allows strings.
ENV['INSTANCE_ID'] = Digest::SHA1.hexdigest("#{ENV['HOSTNAME']}#{ENV['PID']}")
ENV['TMP_PATH'] = DIR+"/tmp_files/#{ENV['INSTANCE_ID']}/scratch_processes"

require DIR+'/model'
models = [
  "analysis_metadata", "analytical_offering", "analytical_offering_variable", "analytical_offering_variable_descriptor", "auth_user", "curation",
  "dataset", "edge", "entity", "graph", "graph_point", "instance", "lock", "mail", "researcher", "tweet", "user", "whitelisting"
]
models.collect{|model| require DIR+'/models/'+model}


require DIR+'/utils/tweet_helper'
require DIR+'/utils/entity_helper'

require DIR+'/utils/u'
require DIR+'/lib/tweetstream'

env = ENV["e"] || "development"
database = YAML.load(File.read(ENV['PWD']+'/config/database.yml'))
if !database.has_key?(env)
  env = "development"
end
database = database[env]
DataMapper.finalize
DataMapper.setup(:default, "#{database["adapter"]}://#{database["username"]}:#{database["password"]}@#{database["host"]}/#{database["database"]}")

storage = YAML.load(File.read(ENV['PWD']+'/config/storage.yml'))
if !storage.has_key?(env)
  env = "development"
end
STORAGE = storage[env]
TIME_OFFSET = NET::NTP.get_ntp_response()["Receive Timestamp"] - Time.now.to_f

require DIR+'/analyzer/analysis'

Twit = Twitter::Client.new