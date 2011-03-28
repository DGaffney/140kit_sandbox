namespace :researchers do 
  desc "Create a researcher account"
  task :new => :environment do 
    create_researcher
  end

  def create_researcher
    researcher = Researcher.new
    puts "What is the username for this account?"
    answer = Sh::clean_gets
    researcher.user_name = answer
    while !researcher.validate_on_create.first
      answer = Sh::clean_gets
      researcher.user_name = answer
      researcher.validate_on_create.last
    end
    puts "What is the password for this account?"
    answer = Sh::clean_gets
    researcher.password = answer
    researcher.send("encrypt_password")
    researcher.save
    researcher
  end

  def load_researcher
    researcher = nil
    if Researcher.count==0
      puts "There are no researchers currently set up. You will need to do this first."
      researcher = create_researcher
    else
      puts "Which researcher do you want to use for the session? Enter username for researcher."
      answer = Sh::clean_gets
      researcher = Researcher.first(:user_name => answer)
      while researcher.nil?
        puts "Sorry, no researcher found for name #{answer}. Try again, or type 'new' to create new researcher"
        answer = Sh::clean_gets
        if answer == "new"
          researcher = create_researcher
        else
          researcher = Researcher.first(:user_name => answer)
        end
      end
    end
    return researcher
  end
end
