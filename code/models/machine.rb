class Machine
  include DataMapper::Resource
  property :id, Serial
  property :user, String
  property :hostname, String
  property :storage_path, String
  property :working_path, String
  property :can_store, Boolean

  def self.determine_storage    
    return self.select_storage_machine || self.fallback_storage_default
  end
  
  def self.fallback_storage_default
    return {"type" => "local", "path" => "#{Git.root_dir}/results"}
  end
  
  def self.select_storage_machine
    machine = Machine.all(:can_store => true).shuffle.first
    storage_type = machine.hostname == ENV["HOSTNAME"] ? "local" : "remote"
    return {"type" => storage_type, "path" => machine.working_path, "user" => machine.user, "hostname" => machine.hostname}
  end
end