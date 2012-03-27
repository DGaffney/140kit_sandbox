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
    
    def lget(*key)
      object = Curation.get(key)
      count = 0
      object.lock
      while object && !object.owned_by_me?
        sleep(1)
        count+=1
        object = Curation.get(key)
        object.lock
        puts "Trying to access locked resource... #{count}"
        return nil if count == 100
      end
      return object
    end
    
    def lall(query=nil)
      objects = []
      if query.nil?
        objects = self.all
      else
        objects = self.all(query)
      end
      locks = objects.collect{|obj| {:with_id => obj.id, :classname => self.to_s, :instance_id => ENV['INSTANCE_ID']}}
      existing_lock_ids = Lock.all(:classname => self.to_s, :with_id => objects.collect(&:id)).collect(&:with_id)
      lockable_locks = locks.select{|l| l if !existing_lock_ids.include?(l[:with_id])}
      Lock.save_all(lockable_locks)
      successes = Lock.all(:instance_id => ENV['INSTANCE_ID']).collect{|x| h=x.attributes;h.delete(:id);h}
      object_ids = (lockable_locks&successes).collect{|x| x[:with_id]}
      objects = objects.select{|object| object if object_ids.include?(object.id)}
      return objects
    end
    
    def ulall(set)
      Lock.all(:with_id => set.collect(&:id), :classname => self, :instance_id => ENV['INSTANCE_ID']).destroy
    end
    
    def lfirst(*args)
      object = self.unlocked.first(args)
      count = 0
      object.lock if !object.nil?
      while object && !object.owned_by_me?
        sleep(1)
        count+=1
        puts "Trying to access locked resource... #{count}"
        object = self.unlocked.first(args)
        object.lock if !object.nil?
        return nil if count == 100
      end
      return object
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
    
    def lock!
      lock = Lock.new(:classname => self.class.to_s, :with_id => self.id, :instance_id => "system")
      lock.save!
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
        
    def locked_by_me?
      return self.owned_by_me?
    end
    
    def owned?
      lock = Lock.first(:classname => self.class.to_s, :with_id => self.id)
      return !lock.nil?
    end    
    
    def locked?
      return self.owned?
    end
  end
  
end

DataMapper::Model.append_extensions(Locking::ClassMethods)
DataMapper::Model.append_inclusions(Locking::InstanceMethods)
