#note: Changing the order of some of these requires may screw things up. 
#Don't do it if you're not sure.
require 'rubygems'
require 'bundler/setup'
require 'dm-core'
require 'dm-aggregates'
require 'dm-chunked_query'
require 'dm-validations'
require 'dm-migrations'
require 'dm-migrations/migration_runner'

require 'extensions/dm-extensions'
require 'extensions/array'
require 'extensions/string'
require 'extensions/hash'
require 'extensions/time'
require 'extensions/date'
require 'extensions/date_time'
require 'extensions/inflectors'

require 'utils/git'
require 'utils/sh'

require 'model'
require 'models/analysis_metadata'
require 'models/analytical_offering'
require 'models/analytical_offering_variable'
require 'models/analytical_offering_variable_descriptor'
require 'models/auth_user'
require 'models/curation'
require 'models/dataset'
require 'models/edge'
require 'models/entity'
require 'models/graph'
require 'models/graph_point'
require 'models/instance'
require 'models/lock'
require 'models/researcher'
require 'models/tweet'
require 'models/user'
require 'models/whitelisting'

require 'utils/tweet_helper'
require 'utils/entity_helper'

require 'utils/u'
require 'lib/tweetstream'
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

require 'analyzer/analysis'

Twit = Twitter::Client.new

ROOT = File.dirname(__FILE__)