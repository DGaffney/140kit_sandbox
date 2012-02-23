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
    
    def first_locked(conditions={})
      return locked.first(conditions)
    end
    
    def last_locked(conditions={})
      return locked.last(conditions)
    end
    
    def first_unlocked(conditions={})
      return unlocked.first(conditions)
    end
    
    def last_unlocked(conditions={})
      return unlocked.last(conditions)
    end
    
    def locked(conditions={})
      all({:id => locked_ids}.merge(conditions))
    end

    def unlocked(conditions={})
      all({:id.not => locked_ids}.merge(conditions))
    end
    
    def unlock_all
      Lock.all(:classname => self).destroy
    end
    
    def lock_all
      locks = []
      all(:fields => [:id]).each do |object|
        locks << {:classname => self, :with_id => object.id, :instance_id => "SYSTEM"}
      end
      Lock.save_all(locks)
      Lock.all(:classname => self, :instance_id.not => "SYSTEM").destroy
    end
    
    def lock(objects=self)
      objects = [objects].flatten
      locked_objects = []
      objects.each do |object|
        object = self.first(object)||self.first(:id => object[:id])||self.new(object) if object.class == Hash
        object = object.lock
        locked_objects << object if object
      end
      return locked_objects
    end
    
    def unlock(objects=self)
      objects = [objects].flatten
      unlocked_objects = []
      objects.each do |object|
        object = self.first(object)||self.first(:id => object[:id])||self.new(object) if object.class == Hash
        object = object.unlock
        unlocked_objects << object if object
      end
      return unlocked_objects
    end
    
    def unlock!(objects=self)
      objects = [objects].flatten
      unlocked_objects = []
      objects.each do |object|
        object = self.first(object)||self.first(:id => object[:id])||self.new(object) if object.class == Hash
        object = object.unlock!
        unlocked_objects << object if object
      end
      return unlocked_objects
    end
    
  private

    def locked_ids
      Lock.all(:fields => [:with_id], :classname => name).map { |l| l.with_id }
    end
  end
  
  module InstanceMethods
    def lock
      lock = Lock.first(:classname => self.class.to_s, :with_id => self.id)
      return nil if lock && lock.instance_id != ENV['INSTANCE_ID']
      return self if lock && lock.instance_id == ENV['INSTANCE_ID']
      if lock.nil?
        lock = Lock.new(:classname => self.class.to_s, :with_id => self.id, :instance_id => ENV['INSTANCE_ID'])
        lock.save!
        sleep(3)
        other_potential_locks = Lock.all(:classname => self.class.to_s, :with_id => self.id).collect{|lock| lock.instance_id}
        if ENV['INSTANCE_ID'] != other_potential_locks.sort.last
          lock.destroy
          return nil
        else
          return self
        end
      end
    end
    
    def unlock
      lock = Lock.first(:classname => self.class.to_s, :with_id => self.id, :instance_id => ENV['INSTANCE_ID'])
      if lock
        lock.destroy 
        return self
      else
        return nil
      end
    end

    def unlock!
      lock = Lock.first(:classname => self.class.to_s, :with_id => self.id)
      if lock
        lock.destroy 
        return self
      else
        return nil
      end
    end

    def owned_by_me?
      lock = Lock.first(:classname => self.class.to_s, :with_id => self.id, :instance_id => ENV['INSTANCE_ID'])
      return !lock.nil? && Lock.all(:classname => self.class.to_s, :with_id => self.id).count == 1
    end    

    def owned?
      lock = Lock.first(:classname => self.class.to_s, :with_id => self.id)
      return !lock.nil?
    end    
  end
  
end

DataMapper::Model.append_extensions(Locking::ClassMethods)
DataMapper::Model.append_inclusions(Locking::InstanceMethods)