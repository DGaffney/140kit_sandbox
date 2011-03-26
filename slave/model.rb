module Locking
  module ClassMethods

    def attributes
      self.properties.collect{|p| p.name}
    end

    def pluralize
      self.to_s.underscore.concat("s")
    end

    def underscore
      return self.to_s.underscore
    end

    def all_deleted(conditions={})
      return self.with_deleted.all(conditions)
    end

    def first_deleted(conditions={})
      return self.with_deleted.first(conditions)
    end

    def find_deleted(conditions={})
      return self.with_deleted.find(conditions)
    end
    
    def first_locked
      return locked.first
    end
    
    def last_locked
      return locked.last
    end
    
    def first_unlocked
      return unlocked.first
    end
    
    def last_unlocked
      return unlocked.last
    end
    
    def locked
      all(:id => locked_ids)
    end

    def unlocked
      all(:id.not => locked_ids)
    end

  private

    def locked_ids
      Lock.all(:fields => [:with_id], :classname => name).map { |l| l.with_id }
    end
  end
  
  module InstanceMethods
    def unlock!
      # obj.unlock!
      # to be used for debugging mainly
      lock = Lock.first(:classname => self.class.to_s, :with_id => self.id)
      lock.nil? ? true : lock.destroy
    end
  end
  
end

DataMapper::Model.append_extensions(Locking::ClassMethods)
DataMapper::Model.append_inclusions(Locking::InstanceMethods)