namespace :unlock do
  desc "Unlock all locked objects"
  task :all => :environment do 
    affected_objectss = 0
    Lock.all.each do |l|
      l.destroy
      affected_objectss+=1
    end
    puts "Unlocked #{affected_objectss} objects"
  end

  desc "Unlock all locked auth_users"
  task :auth_users => :environment  do 
    affected_users = 0
    Lock.all.each do |l|
      if l.classname=="AuthUser"
        l.destroy
        affected_users+=1
      end
    end
    puts "Unlocked #{affected_users} auth_users"
  end
  
end
