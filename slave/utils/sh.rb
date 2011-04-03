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
    response = STDIN.gets
    response = response.chomp
    exit 0 if response=="exit"
    return response
  end
  
  def self.clean_gets_yes_no(prompt=nil, retry_prompt="Sorry, one more time:")
    max_retries = 1000
    puts prompt+" (y/n)" if !prompt.nil?
    answer = Sh::clean_gets
    retries = 0
    while answer!="y" && answer!="n"
      retries+=1
      return nil if retries >= max_retries
      puts retry_prompt if !prompt.nil?
      answer = Sh::clean_gets
    end
    return answer=="y"
  end

  def self.mkdir(folder_location)
    Sh::sh("mkdir -p #{folder_location}")
  end
end

