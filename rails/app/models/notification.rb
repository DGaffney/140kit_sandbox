class Notification
  attr_accessor :twitter

  def initialize(user_name="140kitRobot")
    researcher = Researcher.where(:user_name => user_name).first
    self.twitter = TwitterOAuth::Client.new(
      :consumer_key => Setting.where(:name => "consumer_key", :var_type => "Site Consumer Key").first.actual_value,
      :consumer_secret => Setting.where(:name => "consumer_secret", :var_type => "Site Consumer Secret").first.actual_value,
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