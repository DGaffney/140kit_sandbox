#note: Changing the order of some of these requires may screw things up. 
#Don't do it if you're not sure.
require 'rubygems'
require 'bundler/setup'
require 'dm-core'
require 'dm-aggregates'
require 'dm-validations'
require 'dm-migrations'
require 'dm-migrations/migration_runner'
require 'eventmachine'
require 'em-http'
require 'json'
require 'twitter'

DIR = File.dirname(__FILE__)

require DIR+'/extensions/dm-extensions'
require DIR+'/extensions/array'
require DIR+'/extensions/string'
require DIR+'/extensions/hash'
require DIR+'/extensions/time'
require DIR+'/extensions/date'
require DIR+'/extensions/date_time'
require DIR+'/extensions/inflectors'

require DIR+'/utils/git'
require DIR+'/utils/sh'

require DIR+'/model'
require DIR+'/models/analysis_metadata'
require DIR+'/models/analytical_offering'
require DIR+'/models/analytical_offering_variable'
require DIR+'/models/analytical_offering_variable_descriptor'
require DIR+'/models/auth_user'
require DIR+'/models/curation'
require DIR+'/models/dataset'
require DIR+'/models/edge'
require DIR+'/models/entity'
require DIR+'/models/graph'
require DIR+'/models/graph_point'
require DIR+'/models/instance'
require DIR+'/models/lock'
require DIR+'/models/researcher'
require DIR+'/models/tweet'
require DIR+'/models/user'
require DIR+'/models/whitelisting'


require DIR+'/utils/tweet_helper'
require DIR+'/utils/entity_helper'

require DIR+'/utils/u'
require DIR+'/lib/tweetstream'

env = ENV["e"] || "development"
db = YAML.load(File.read(ENV['PWD']+'/config/database.yml'))
if !db.has_key?(env)
  env = "development"
end
db = db[env]
DataMapper.finalize
DataMapper.setup(:default, "#{db["adapter"]}://#{db["username"]}:#{db["password"]}@#{db["host"]}/#{db["database"]}")

require DIR+'/analyzer/analysis'

Twit = Twitter::Client.new

ROOT = DIR