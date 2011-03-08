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
    return response
  end
end