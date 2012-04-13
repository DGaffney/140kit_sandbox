require File.dirname(__FILE__)+'/whitelisting'
require File.dirname(__FILE__)+'/lock'
# require 'YAML'

class Instance
  include DataMapper::Resource
  property :id,             Serial
  property :instance_id,    String, :length => 40
  property :hostname,       String, :unique_index => [:unique_instance], :default => ENV['HOSTNAME']
  property :pid,            Integer, :unique_index => [:unique_instance], :default => ENV['PID']
  property :updated_at,     Time
  property :killed,         Boolean, :default => false
  property :instance_type,  String, :unique_index => [:unique_instance]
  
  # validates_presence_of :instance_type
  # validates_presence_of :instance_id
  # validates_uniqueness_of :instance_id
  
  attr_accessor :metadata, :rest_allowed, :last_count_check, :tmp_path, :tmp_data, :check_in_thread
  
  @sleep_constant = lambda{Setting.first(:name => "sleep_constant", :var_type => "Instance Settings").value} rescue 30
  
  def initialize
    super
    self.rest_allowed = whitelisted?
    self.tmp_data = {}
    self.instance_id = ENV['INSTANCE_ID']
    puts "Hello, my name is #{self.instance_id}."
  end
  
  def connect_to_db
    env = ARGV.include?("e") ? ARGV[ARGV.index("e")+1]||"production" : "production"
    db = YAML.load(File.read(ENV['PWD']+'/../config/database.yml'))
    if !db.has_key?(env)
      puts "No such environment #{env}."
      env = "production"
    end
    puts "Booting #{env} environment."
    db = db[env]
    DataMapper.finalize
    DataMapper.setup(:default, "#{db["adapter"]}://#{db["username"]}:#{db["password"]}@#{db["host"]}:#{db["port"] || 3000}/#{db["database"]}")
  end
  
  def check_in
    Sh::mkdir(ENV['TMP_PATH'], {"type"=>"local"})
    @check_in_thread = Thread.new { loop { self.touch; sleep(60) } }
  end
  
  def whitelisted?
    # return Whitelisting.first(:conditions => {:hostname => self.hostname}).nil? ? false : Whitelisting.first(:conditions => {:hostname => self.hostname}).whitelisted
    wl = Whitelisting.first({:hostname => self.hostname})
    return false if wl.nil?
    return Whitelisting.first(:hostname => self.hostname).whitelisted
  end
  
  def killed?
    self.reload
    self.killed
  end
  
  def unlock_all
    Lock.all(:instance_id => self.instance_id).destroy
  end
end