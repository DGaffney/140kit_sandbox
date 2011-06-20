namespace :curation do
  desc "Create a new curation."
  task :new => :environment do
    researcher = load_researcher
    puts "What type of curation will this be? (Can choose from: #{Dataset.scrape_types.inspect})"
    answer = Sh::clean_gets
    while !Dataset.scrape_types.include?(answer)
      puts "Sorry, that wasn't one of the options. Type the exact name please."
      answer = Sh::clean_gets
    end
    dataset = Dataset.new
    dataset.scrape_type = answer
    clean_params = validate_params(answer)
    dataset.params = clean_params
    if dataset.scrape_type != "import" && dataset.scrape_type != "audience_profile"
      puts "How long would you like to have this collection run? (Enter in number of seconds. I know, that's annoying.)"
      answer = Sh::clean_gets
      while answer.to_i==0
        puts "Sorry, we couldn't parse that value. Just numbers, please, you know, like '300'."
        answer = Sh::clean_gets
      end
      dataset.length = answer
    end
    dataset.save
    curation = create_curation(dataset, researcher)
    select_analysis_metadata(curation)
  end

  desc "Manage existing Curations"
  task :manage => :environment do
    puts "First, I'll need to get the name of the researcher whose curations you want to manage:"
    researcher = load_researcher
    puts "Researcher #{researcher.user_name} has #{researcher.curations.length} active curations."
    researcher.curations.each do |curation|
      puts "ID: #{curation.id} Name: #{curation.name} Date Created: #{curation.created_at} Number of Datasets: #{curation.datasets.length}"
    end
    manage_curations(researcher)
  end
  
  def manage_curations(researcher)
    puts "Type 'man curation_id' to see more information about a curation"
    puts "Type 'archives' to see the archived curations for this researcher"
    puts "Type 'archive curation_id' to archive a curation"
    puts "Type 'unarchive curation_id' to reactivate a curation"
    puts "Type 'finish' at any time to go up one level in management" 
    puts "Type 'exit' at any time to boot out" 
    answer = Sh::clean_gets
    while answer!="finish"
      if answer[0..2] == "man"
        curation = Curation.first(:id => answer.gsub("man ", ""))
        puts "Curation not found!" if curation.nil?
        if !curation.nil?
          puts "From here, you can do all sorts of stuff:"
          puts "Type 'list' to see current stats about this curation"
          puts "Type 'analyze' to select analysis processes for the curation"
          puts "Type 'remove function_name' to clear an analysis process for the curation"
          puts "Type 'clear' to clear all analysis processes for the curation"
          puts "Type 'finish' to exit the curation and return to management."
          answer = Sh::clean_gets
          while answer!="finish"
            if answer == "list"
              puts "Curation Stats:"
              puts "Tweets: #{curation.tweets_count}"
              puts "Users: #{curation.users_count}"
              puts "Total Analytical Processes: #{curation.analysis_metadatas.count}"
              curation.analysis_metadatas.each do |am|
                puts am.display_terminal
              end
            elsif answer == "analyze"
              select_analysis_metadata(curation)
            elsif answer[0..6] == "remove "
              remove_analysis_metadata(answer, curation)
            elsif answer == "clear"
              curation.analysis_metadatas.each do |am|
                am.clear
              end
            end
            answer = Sh::clean_gets
          end
        end
      elsif answer=="archives"
        curations = Curation.all_deleted(:researcher_id => researcher.id)
        if curations.blank?
          puts "#{researcher.user_name}'s archive is empty."
        else
          curations.each do |curation|
            puts "ID: #{curation.id} Name: #{curation.name} Date Created: #{curation.created_at} Number of Datasets: #{curation.datasets.length}"
          end
          puts "Note: you must unarchive a curation in order to manage it."
        end
      elsif answer[0..6]=="archive"
        puts "Archiving Curation.."
        curation = Curation.first(:id => answer.gsub("archive ", ""))
        if curation
          if curation.researcher == researcher
            curation.archived = true
            curation.save
            puts "Curation successfully archived!"
          else
            puts "You can't archive a curation you do not own!"
          end
        else
          puts "Curation not found. Try again."
        end
      elsif answer[0..8]=="unarchive"
        puts "Unarchiving Curation.."
        curation = Curation.first_deleted(:id => answer.gsub("unarchive ", ""))
        if curation
          if curation.researcher == researcher
            curation.archived = false
            curation.save
            puts "Curation successfully unarchived!"
          else
            puts "You can't unarchive a curation you do not own!"
          end
        else
          puts "Curation not found. Try again."
        end
      else
        puts "Sorry, I didn't understand your entry. Try again?"
        answer = Sh::clean_gets
      end
      puts "Type 'man curation_id' to see more information about a curation"
      puts "Type 'archives' to see the archived curations for this researcher"
      puts "Type 'archive curation_id' to archive a curation"
      puts "Type 'unarchive curation_id' to reactivate a curation"
      puts "Type 'finish' at any time to boot out of management"
      answer = Sh::clean_gets
    end
  end
  
  def create_curation(dataset, researcher)
    name = dataset.params
    answer = Sh::clean_gets_yes_no("Currently, the curation will be named: #{dataset.params}. Change this?", "Sorry, one more time:")
    if answer
      puts "Enter name:"
      name = Sh::clean_gets
      answer = Sh::clean_gets_yes_no("Currently, the curation will be named: #{name}. Change this?", "Sorry, one more time:")
      while answer
        answer = Sh::clean_gets_yes_no("Currently, the curation will be named: #{name}. Change this?", "Sorry, one more time:")
        puts "Enter name:"
        name = Sh::clean_gets
      end
    end
    curation = Curation.new
    curation.name = name
    curation.researcher = researcher
    curation.datasets << dataset
    curation.save
    curation
  end
  
  def validate_params(scrape_type)
    response = {}
    case scrape_type
    when "track"
      puts "A track scrape will track and collect all Tweets (and Users), from now until when you specify, for a given word or phrase.\n Enter phrase now:"
      answer = Sh::clean_gets
      response = Dataset.valid_params("track", answer)
      while !response[:reason].empty?
        puts "Sorry, that was not valid input. Reason: #{reason}"
        answer = Sh::clean_gets
        response = Dataset.valid_params("track", answer)
      end
    when "follow"
      puts "A follow scrape will follow and collect all Tweets from a given set of users (screen names only), from now until when you specify.\n Enter users, delimited by commas, now:"
      answer = Sh::clean_gets
      response = Dataset.valid_params("follow", answer)
      while !response[:reason].empty?
        puts "Sorry, that was not valid input. Reason: #{reason}"
        answer = Sh::clean_gets
        response = Dataset.valid_params("follow", answer)
      end
    when "locations"
      puts "A locations scrape will track and collect all Tweets (and Users), from now until when you specify, for a\n given geographic area entered like: -74,40,-73,41 (A one-degree square\n from -74 and 40 to -73 and 41. Decimals are acceptable to any accuracy).\n Enter phrase now:"
      answer = Sh::clean_gets
      response = Dataset.valid_params("locations", answer)
      while !response[:reason].empty?
        puts "Sorry, that was not valid input. Reason: #{reason}"
        answer = Sh::clean_gets
        response = Dataset.valid_params("locations", answer)
      end
    when "import"
      puts "An import scrape will pull data from a file location (can be a compressed file or folder, a folder, a file, or a url from either 140kit or TwapperKeeper legacy datasets). Please enter your import location:"
      answer = Sh::clean_gets
      response = Dataset.valid_params("import", answer)
      while !response[:reason].empty?
        puts "Sorry, that was not valid input. Reason: #{reason}"
        answer = Sh::clean_gets
        response = Dataset.valid_params("import", answer)
      end
    when "audience_profile"
      puts "An audience profiler scrape will collect all tweets and user information from public users who follow a particular account. Additionally, it will add in follower network information at a regular interval. Enter the user name of the account you wish to profile:"
      answer = Sh::clean_gets
      response = Dataset.valid_params("audience_profile", answer)
      while !response[:reason].empty?
        puts "Sorry, that was not valid input. Reason: #{reason}"
        answer = Sh::clean_gets
        response = Dataset.valid_params("audience_profile", answer)
      end
    end
    return response[:clean_params]
  end
end
