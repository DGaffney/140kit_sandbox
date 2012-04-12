class Twit < ActiveRecord::Base
  def self.get_credentials
    consumer_key = Setting.find_by_name_and_var_type("consumer_key", "Site Consumer Key").actual_value
    consumer_secret = Setting.find_by_name_and_var_type("consumer_secret", "Site Consumer Secret").actual_value
    researcher = Researcher.first(:order => "rand()")
    return {
      :consumer_key => consumer_key,
      :consumer_secret => consumer_secret,
      :oauth_token => researcher.oauth_token,
      :oauth_token_secret => researcher.oauth_token_secret
    }
  end
  
  def self.client(credentials=self.get_credentials)
    Twitter::Client.new(credentials)
  end
end