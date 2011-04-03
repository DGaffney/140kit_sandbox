require File.dirname(__FILE__)+'/../environment'
require 'ruby-debug'
require 'dm-sweatshop'
include DataMapper::Sweatshop::Unique 
require 'rake'
env = ENV["e"] || "test"
database = YAML.load(File.read(ENV['PWD']+'/config/database.yml'))
if !database.has_key?(env)
  DataMapper.finalize
  DataMapper.setup(:default, "sqlite::memory:")
else
  database = database[env]
  DataMapper.finalize
  DataMapper.setup(:default, "#{database["adapter"]}://#{database["username"]}:#{database["password"]}@#{database["host"]}/#{database["database"]}")
end

DataMapper.auto_migrate!
load 'config/seed.rb'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

FileList[DIR+'/spec/fixtures/*.rb'].each { |task| require task.gsub(".rb", "")}