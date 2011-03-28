module Sh
  def self.hostname
    return sh "hostname"
  end
  
  def self.sh(command, chomped=true)
    result = `#{command}`
    result = result.chomp if chomped
    return result
  end
  
  def self.clean_gets
    STDOUT.flush
    response = STDIN.gets.chomp
    exit 0 if response=="exit"
    return response
  end
  
  def self.clean_gets_yes_no(prompt, retry_prompt="Sorry, one more time:")
    puts prompt+" (y/n)"
    answer = Sh::clean_gets
    while answer!="y" && answer!="n"
      puts retry_prompt
      answer = Sh::clean_gets
    end
    return answer=="y"
  end

  def self.mkdir(folder_location)
    Sh::sh("mkdir -p #{folder_location}")
    # start_position = if folder_location.split("").first == "/"
    #   "/"
    # elsif folder_location.split("").first == "../"
    # folder_location.split("/").select{|d| !d.blank?}.repack do |dir| 
    #   begin
    #   directory_name = dir.join("/")
    #   if FileTest::directory?(directory_name)
    #   return
    #   end
    #   Dir::mkdir(directory_name)
    #   end      
    # end
  end
end

