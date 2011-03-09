#note: Changing the order of some of these requires may screw things up. 
#Don't do it if you're not sure.
require 'rubygems'
require 'bundler/setup'
require 'dm-core'
require 'dm-aggregates'
require 'dm-validations'

require 'extensions/dm-extensions'
require 'extensions/array'
require 'extensions/string'
require 'extensions/hash'
require 'extensions/time'
require 'extensions/date'

require 'utils/git'
require 'utils/sh'

require 'models/analysis_metadata'
require 'models/analytical_offering'
require 'models/analytical_offering_variable'
require 'models/auth_user'
require 'models/curation'
require 'models/dataset'
require 'models/edge'
require 'models/graph'
require 'models/graph_point'
require 'models/instance'
require 'models/lock'
require 'models/researcher'
require 'models/tweet'
require 'models/user'
require 'models/whitelisting'

require 'utils/tweet_helper'
require 'utils/u'
require 'lib/tweetstream'

require 'eventmachine'
require 'em-http'
require 'json'
require 'twitter'

Twit = Twitter::Client.new