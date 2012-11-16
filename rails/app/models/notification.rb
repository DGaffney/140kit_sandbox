class Notification
  attr_accessor :twitter

  def initialize(user_name="140kitRobot")
    researcher = Researcher.first(:conditions => {:user_name => user_name})
    self.twitter = TwitterOAuth::Client.new(
      :consumer_key => Setting.first(:conditions => {:name => "consumer_key", :var_type => "Site Consumer Key"}).value,
      :consumer_secret => Setting.first(:conditions => {:name => "consumer_secret", :var_type => "Site Consumer Secret"}).value,
      :token => researcher.oauth_token,
      :secret => researcher.oauth_token_secret
    )
    self.twitter.authorized?
  end
  
  def self.post(content)
    if content.length < 140
      n = Notification.new
      n.twitter.update(content)
      return true
    else
      return false
    end
  end
end