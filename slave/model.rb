class Model
  def self.underscore
    return self.to_s.underscore
  end
  
  def self.all_deleted(conditions={})
    return self.with_deleted.all(conditions)
  end

  def self.first_deleted(conditions={})
    return self.with_deleted.first(conditions)
  end

  def self.find_deleted(conditions={})
    return self.with_deleted.find(conditions)
  end

end