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
require 'open-uri'
require 'twitter'
require 'tweetstream'
require 'iconv'
require 'unicode'
require 'csv'
require 'useful_class_extensions'
require 'twitter_oauth'
#Encoding.default_external = Encoding::ISO_8859_1
#Encoding.default_internal = Encoding::ISO_8859_1
DIR = File.dirname(__FILE__)
THIS_DIR = ARGV.include?("d") ? ARGV[ARGV.index("d")+1]||DIR : DIR
require DIR+'/extensions/inflectors'

require DIR+'/utils/git'
require DIR+'/utils/sh'
require DIR+'/utils/notification'
require DIR+'/extensions/string'
require DIR+'/extensions/array'
ENV['TZ'] = "UTC"
ENV['HOSTNAME'] = Sh::hostname.strip
ENV['PID'] = Process.pid.to_s #because ENV only allows strings.
ENV['INSTANCE_ID'] = Digest::SHA1.hexdigest("#{ENV['HOSTNAME']}#{ENV['PID']}")
ENV['TMP_PATH'] = THIS_DIR+"/tmp_files/#{ENV['INSTANCE_ID']}/scratch_processes/"
ENV['QUIET'] = "false"
require DIR+'/model'
models = [
  "analysis_metadata", "analytical_offering", "analytical_offering_requirement", "analytical_offering_variable", "analytical_offering_variable_descriptor", "auth_user", "coordinate", "curation",
  "dataset", "edge", "friendship", "entity", "geo", "graph", "graph_point", "importer_task", "instance", "location", "lock", "machine", "mail", "parameter", "post", 
  "researcher", "setting", "tag", "ticket", "trending_topic", "tweet", "user", "whitelisting", "worker_description"
]
models.collect{|model| require DIR+'/models/'+model}

require DIR+'/utils/geo_helper'
require DIR+'/utils/coordinate_helper'
require DIR+'/utils/tweet_helper'
require DIR+'/utils/entity_helper'

require DIR+'/utils/u'
# require DIR+'/lib/tweetstream'
DEFAULT_ENV = "production"
ENV['E'] = ARGV.include?("e") ? ARGV[ARGV.index("e")+1]||DEFAULT_ENV : DEFAULT_ENV
puts "Starting #{ENV['E']} environment..."

database = YAML.load(File.read(DIR+'/config/database.yml'))
if !database.has_key?(ENV['E'])
  env = "production"
end
database = database[ENV['E']]
database.inspect
DataMapper.setup(:default, "#{database["adapter"]}://#{database["username"]}:#{database["password"]}@#{database["host"]}:#{database["port"] || 3000}/#{database["database"]}?encoding=UTF-8").inspect
DataMapper.finalize
STORAGE = Machine.determine_storage rescue {"type" => "local", "path" => THIS_DIR, "user" => Sh::whoami.strip, "hostname" => Sh::hostname.strip}
require DIR+'/extensions/dm-extensions'

#require DIR+'/analyzer/analysis'


Twit = Twitter::Client.new

at_exit { do_at_exit }

def do_at_exit
  safe_close
  puts "Safely exited."
end

def safe_close
  pid = ENV['PID']
  hostname = Sh::hostname
  instance_id = ENV['INSTANCE_ID']
  instance = Instance.first(:hostname => hostname, :pid => pid) || Instance.first(:instance_id => instance_id)
  if instance
    case instance.instance_type
    when "worker"
      instance.store_data(1)
      instance.unlock_all
    when "streamer"
      instance.store_data(1)
      instance.unlock_all
    end
    instance.destroy
  else
    Lock.all(:instance_id => instance_id).destroy
  end
end

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
