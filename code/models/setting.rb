class Setting
  include DataMapper::Resource
  property :id, Serial, :serial => true
  property :name, String
  property :var_type, String
  property :var_class, String
  property :value, Object
  
  def self.grab(var_type)
    settings = self.all(:var_type => var_type)
    result = {}
    settings.each do |x|
      result[x.name.to_sym] = x.value
    end
    return result
  end
end