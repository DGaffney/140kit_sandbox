#note: Changing the order of some of these requires may screw things up. 
#Don't do it if you're not sure.
require 'rubygems'
require 'bundler/setup'
require 'dm-core'
require 'dm-aggregates'
require 'dm-validations'
require 'dm-migrations'
require 'dm-migrations/migration_runner'

require File.dirname(__FILE__)+'/extensions/dm-extensions'
require File.dirname(__FILE__)+'/extensions/array'
require File.dirname(__FILE__)+'/extensions/string'
require File.dirname(__FILE__)+'/extensions/hash'
require File.dirname(__FILE__)+'/extensions/time'
require File.dirname(__FILE__)+'/extensions/date'
require File.dirname(__FILE__)+'/extensions/date_time'
#require File.dirname(__FILE__)+'/extensions/inflectors'

require File.dirname(__FILE__)+'/utils/git'
require File.dirname(__FILE__)+'/utils/sh'

require File.dirname(__FILE__)+'/models/analysis_metadata'
require File.dirname(__FILE__)+'/models/analytical_offering'
require File.dirname(__FILE__)+'/models/analytical_offering_variable'
require File.dirname(__FILE__)+'/models/analytical_offering_variable_descriptor'
require File.dirname(__FILE__)+'/models/auth_user'
require File.dirname(__FILE__)+'/models/curation'
require File.dirname(__FILE__)+'/models/dataset'
require File.dirname(__FILE__)+'/models/edge'
#require File.dirname(__FILE__)+'/models/entity'
require File.dirname(__FILE__)+'/models/graph'
require File.dirname(__FILE__)+'/models/graph_point'
require File.dirname(__FILE__)+'/models/instance'
require File.dirname(__FILE__)+'/models/lock'
require File.dirname(__FILE__)+'/models/researcher'
require File.dirname(__FILE__)+'/models/tweet'
require File.dirname(__FILE__)+'/models/user'
require File.dirname(__FILE__)+'/models/whitelisting'

require File.dirname(__FILE__)+'/utils/tweet_helper'
#require File.dirname(__FILE__)+'/utils/entity_helper'

require File.dirname(__FILE__)+'/utils/u'
require File.dirname(__FILE__)+'/lib/tweetstream'
require 'eventmachine'
require 'em-http'
require 'json'
require 'twitter'

env = ENV["e"] || "development"
db = YAML.load(File.read(ENV['PWD']+'/config/database.yml'))
if !db.has_key?(env)
  env = "development"
end
db = db[env]
DataMapper.finalize
DataMapper.setup(:default, "#{db["adapter"]}://#{db["username"]}:#{db["password"]}@#{db["host"]}/#{db["database"]}")

require File.dirname(__FILE__)+'/analyzer/analysis'

Twit = Twitter::Client.new

ROOT = File.dirname(__FILE__)