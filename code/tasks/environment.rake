namespace :environment do

  desc "Load 140kit environment"
  task :load do 
    require File.dirname(__FILE__)+'/../environment'
  end
  # task :default => Rake::Task["environment:load"].execute  

  def load_settings
    env = ENV["e"] || "development"
    db = YAML.load(File.read(ENV['PWD']+'/config/database.yml'))
    if !db.has_key?(env)
      puts "No such environment #{env}."
      env = "development"
    end
    puts "Booting #{env} environment."
    db = db[env]
    return db
  end
  
end
