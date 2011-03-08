class Whitelisting
  include DataMapper::Resource
  property :id, Serial
  property :hostname, String, :key => true, :unique_index => [:unique_whitelisting]
  property :ip, String, :unique_index => [:unique_whitelisting]
  property :whitelisted, Boolean, :default => 0, :unique_index => [:unique_whitelisting]
end