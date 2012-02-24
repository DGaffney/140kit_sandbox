module Git
  def self.url
    Sh::sh("git remote -v").split("\n").first.split(" ")[1]
  end
  
  def self.branch
    Sh::sh("git branch").split("\n").collect{|b| b.gsub("\* ", "") if b.include?("* ")}.compact.first
  end
  
  def self.url_repo
    branch = Git::branch
    url = Git::url
    url = url.gsub(".com:", ".com/").gsub("git\@", "http://www.").gsub(/\.git$/, "")+"/tree/"+branch+"/"+Git::this_dir+"/" rescue "blah"
    return url
  end
  
  def self.root_dir
    Sh::sh("git rev-parse --git-dir").gsub(".git", "").strip
  end
  
  def self.this_dir
    ENV['PWD'].gsub(Git::root_dir, "")
  end
  
end
