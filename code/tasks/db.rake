namespace :db do
  
  desc "Migrate the database up from current location to either specified migration or to latest"
  task :migrate => :environment do
    answer = Sh::clean_gets_yes_no("Warning! A migrate will drop all current tables, and refresh the system. It is good to do this on first run, \n or if something horrible has happened. Otherwise, please, for your own sake, run `rake db:export` before doing this.\n That said, do you want to continue?")
    if answer
      DataMapper.auto_migrate!
    end
  end

  desc "Seed database with core data that you'll probably want"
  task :seed => :environment do
    load 'config/seed.rb'
  end
  desc "Attempt to upgrade database. Note: this will possibly not add indexes added to the new models, do to ORM limitations."
  task :upgrade => :environment do
    DataMapper.auto_upgrade!
  end
  
  desc "Dump all tables into a set of sql dump files, and, in turn, dump the files into a large zip directory. Pass in location via EXPORT_PATH (default is 'dump.sql'). Get it out of your system so you can cleanly start fresh without necessarily losing the data. WARNING: Currently only supported for mysql."
  task :export do
    file = ENV['EXPORT_PATH']||ENV['export_path']||ENV['Export_path']||"dump.sql"
    mysqldump_path = Sh::sh("which mysqldump")
    if mysqldump_path.empty?
      puts "Cannot run process until you install mysqldump itself. Exiting."
    else
      answer = Sh::clean_gets_yes_no("This will run mysqldump on your environment's database, which may take time, depending on how much Twitter junk you've collected. Proceed?")
      if answer
        db = load_settings
        puts "Running export now... Promise."
        sh "mysqldump -h #{db["host"]} -u #{db["username"]} --password=#{db["password"]} #{db["database"]} > #{file}"
      end
    end
  end
  desc "Import a dataset from your local file system. Pass in location via IMPORT_PATH variable (default is 'dump.sql'). Expects this to be a directory of dump files. WARNING: Currently only supported for mysql."
  task :import do
    file = ENV['EXPORT_PATH']||ENV['export_path']||ENV['Export_path']||"dump.sql"
    mysqldump_path = Sh::sh("which mysql")
    if mysqldump_path.empty?
      puts "Cannot run process until you install mysql itself. Exiting."
    else
      answer = Sh::clean_gets_yes_no("This will run mysql on your environment's database, which may take time, depending on how much Twitter junk you've collected. Proceed?")
      if answer
        db = load_settings
        puts "Running import now... Promise."
        sh "mysql -h #{db["host"]} -u #{db["username"]} --password=#{db["password"]} #{db["database"]} < #{file}"
      end
    end
  end
end
