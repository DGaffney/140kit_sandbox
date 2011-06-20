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

DIR = File.dirname(__FILE__)

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
  "dataset", "edge", "friendship", "entity", "graph", "graph_point", "importer_task", "instance", "jaccard_coefficient", "lock", "mail", "researcher", "tweet", "user", "whitelisting"
]
models.collect{|model| require DIR+'/models/'+model}


require DIR+'/utils/tweet_helper'
require DIR+'/utils/entity_helper'

require DIR+'/utils/u'
require DIR+'/lib/tweetstream'

env = ENV["e"] || "development"
database = YAML.load(File.read(File.dirname(__FILE__)+'/config/database.yml'))
if !database.has_key?(env)
  env = "development"
end
database = database[env]
DataMapper.finalize
DataMapper.setup(:default, "#{database["adapter"]}://#{database["username"]}:#{database["password"]}@#{database["host"]}:#{database["port"] || 3000}/#{database["database"]}")
require DIR+'/extensions/dm-extensions'

storage = YAML.load(File.read(File.dirname(__FILE__)+'/config/storage.yml'))
if !storage.has_key?(env)
  env = "development"
end
STORAGE = storage[env]
TIME_OFFSET = NET::NTP.get_ntp_response()["Receive Timestamp"] - Time.now.to_f

require DIR+'/analyzer/analysis'

Twit = Twitter::Client.new
Struct.new("Condition", :name, :process, :vars)

def connect_to_db(environment_name)
  database = YAML.load(File.read(File.dirname(__FILE__)+'/config/database.yml'))
  if database.has_key?(environment_name)
    database = database[environment_name]
    DataMapper.finalize
    DataMapper.setup(environment_name.to_sym, "#{database["adapter"]}://#{database["username"]}:#{database["password"]}@#{database["host"]}:#{database["port"] || 3000}/#{database["database"]}")
    return DataMapper.repository(environment_name.to_sym).adapter
  else
    puts "Could not connect to database, does not exist in config!"
    return nil
  end
end

def load_config_file(filename)
  files = {}
  Sh::sh("ls #{File.dirname(__FILE__)}/config").split("\n").collect{|f| files[f.scan(/(.*)\..*/).flatten.first] = f}.flatten.compact
  if files[filename]
    return database = YAML.load(File.read(File.dirname(__FILE__)+"/config/#{files[filename]}"))
  else
    return {}
  end
end