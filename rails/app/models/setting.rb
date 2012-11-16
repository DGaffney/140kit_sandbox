class Setting < ActiveRecord::Base
  property :name, String
  def actual_value
    return  Marshal.load(value.unpack('m').first)
  end

  def set_value
    return self.class.set_value(self.value, self.var_class)
  end
  
  def self.set_value(value, var_class)
    if var_class == "string"
      return  [ Marshal.dump(value) ].pack('m')
    elsif var_class == "integer"
      return  [ Marshal.dump(value.to_i) ].pack('m')
    elsif var_class == "array"
      return  [ Marshal.dump(value.split(",")) ].pack('m')
    elsif var_class == "float"
      return  [ Marshal.dump(value.to_f) ].pack('m')
    end
  end

end
