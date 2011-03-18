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
    exit if response=="exit"
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
  
  def self.mkdirs(folder_location)
    folder_location.split("/").repack{|dir| Sh::sh("mkdir #{dir.join("/")}")}
  end
end