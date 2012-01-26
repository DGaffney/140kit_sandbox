load File.dirname(__FILE__)+'/../environment.rb'
class Friendshipper < Instance
  
  attr_accessor :params, :dataset, :users, :tweets, :entities, :friendships, :user, :username
  UPDATE_INTERVAL = 86400
  MAX_FRIENDS = 10000
  
  def initialize
    super
    self.instance_type = "friendshipper"
    @users = []
    @tweets = []
    @entities = []
    @friendships = []
    oauth_settings = YAML.load(File.read(File.dirname(__FILE__)+'/../config/twitter.yml'))
    account = "dgaff"
    Twitter.configure do |config|
      config.consumer_key = oauth_settings[account]["oauth_settings"]["consumer_key"]
      config.consumer_secret = oauth_settings[account]["oauth_settings"]["consumer_secret"]
      config.oauth_token = oauth_settings[account]["access_token"]["access_token"]
      config.oauth_token_secret = oauth_settings[account]["access_token"]["access_token_secret"]
    end
    @start_time = Time.now
    at_exit { do_at_exit }
  end

  def do_at_exit
    puts "Exiting."
    store_data(1)
    self.destroy
  end
  
  def friendship(selected_datasets=[])
    puts "Friendshipping..."
    check_in
    puts "Entering friendshipper routine."
    $instance = self
    loop do
      if !killed?
        profile_routine(selected_datasets)
      else
        puts "Just nappin'."
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def profile_routine(selected_datasets)
    select_dataset(selected_datasets)
    if !@dataset.nil?
      collect_network
      finish_up
    else
      puts "No unlocked audience datasets found - will try again..."
    end
  end
  
  def select_dataset(selected_datasets)
    possible_datasets = []
    if !selected_datasets.empty?
      possible_datasets = Dataset.all(:id => selected_datasets).unlocked
    else
      possible_datasets = Dataset.all(:scrape_type => "scoped_dataset", :scrape_finished => false, :order => [:updated_at.desc]).unlocked
    end
    possible_datasets.each do |dataset|
      locked_dataset = dataset.lock
      (@dataset = locked_dataset; @user = @dataset.users.first; return @dataset )if !locked_dataset.nil?
    end
    return @dataset
  end
  
  def finish_up
    store_data(1)
    @dataset.updated_at = Time.now
    @dataset.scrape_finished = true
    @dataset.tweets_count = Tweet.count(:dataset_id => @dataset.id)
    @dataset.users_count = User.count(:dataset_id => @dataset.id)
    @dataset.save!
    @dataset.unlock!
    @users = []
    @tweets = []
    @entities = []
    @friendships = []
  end
  
  def collect_network
    offset = 0
    limit = 1000
    users = User.all(:dataset_id => @dataset.id, :offset => offset, :limit => limit)
    puts "Working with users #{offset}-#{offset+limit}..."
    while !users.empty?
      users.each do |user|
        begin
          if Friendship.count(:followed_user_name => user.screen_name, :followed_user_id => user.id, :dataset_id => @dataset.id) == 0
            collect_data(user, "follower_ids")
          end
          if Friendship.count(:follower_user_name => user.screen_name, :follower_user_id => user.id, :dataset_id => @dataset.id) == 0
            collect_data(user, "friend_ids")
          end
        rescue
          next
        end
      end
      offset += limit
      users = User.all(:dataset_id => @dataset.id, :offset => offset, :limit => limit)
    end    
  end
  
  def collect_data(user, method="followers")
    puts "Parsing #{user.screen_name}..."
    cursor = -1
    others = nil
    id_groups = nil
    rate_limit_status = Twitter.rate_limit_status
    sleep (Time.parse(rate_limit_status.reset_time)-Time.now)/rate_limit_status.remaining_hits
    others = []
    friendship_ids = Twitter.send(method, user.screen_name, :count => 5000, :cursor => cursor)
    id_groups = friendship_ids.ids
    id_groups.chunk((id_groups.length/100.0).floor+1).each do |id_group|
      others << Twitter.users(id_group)
    end
    others = others.flatten
    finished = false
    while !finished
      count = 0
      others.each do |other|
        count+=others.length
        if !User.find(:screen_name => user.screen_name, :dataset_id => @dataset.id).nil?
          begin
            @friendships << {:followed_user_name => user.screen_name, :followed_user_id => user.id, :follower_user_name => other.screen_name, :follower_user_id => other.id}
            # user_data = TweetHelper.prep_user(other)
            # @users << user_data
            # tweets_and_entities_from_user(other, nil, 0)
            puts "Parsed #{other.screen_name}."
          rescue
            puts "401 on #{other.screen_name}."
            next
          end
        end
      end
      puts "#{@users.length} total users in memory."
      puts "#{@friendships.length} total friendships in memory."
      begin
        store_data
      rescue
        retry
      end
      cursor = friendship_ids.next_cursor
      finished = true if friendship_ids.next_cursor == 0 || count > MAX_FRIENDS
      rate_limit_status = Twitter.rate_limit_status
      sleep (Time.parse(rate_limit_status.reset_time)-Time.now)/rate_limit_status.remaining_hits
      others = []
      id_groups = Twitter.send(method, user.screen_name, :count => 5000, :cursor => cursor).ids
      id_groups.chunk((id_groups.length/100.0).floor+1).each do |id_group|
        Twitter.users(id_group)
      end
      others = others.flatten
    end
    begin
      store_data(1)
    rescue
      retry
    end
  end

  def tweets_and_entities_from_user(user, since_time=nil, max_pages=16)
    page = 1
    raw_tweets = Twit.user_timeline(user.screen_name, :count => 200, :page => page, :include_entities => true, :include_rts => true)
    while !raw_tweets.empty? && page <= max_pages
      @tweets += raw_tweets.collect{|tweet| TweetHelper.prep_tweet(tweet)}
      @entities += raw_tweets.collect{|tweet| EntityHelper.prepped_entities(tweet)}
      return nil if !since_time.nil? && raw_tweets.last.created_at <= since_time
      page+=1
      raw_tweets = Twit.user_timeline(user.screen_name, :count => 200, :page => page, :include_entities => true, :include_rts => true)
    end
    return nil
  end

  def store_data(limit=1000)
    if @users.length >= limit
      User.save_all(@users.collect{|user| user.merge({:dataset_id => @dataset.id})})
      @users = []
    end
    if @tweets.length >= limit
      Tweet.save_all(@tweets.collect{|tweet| tweet.merge({:dataset_id => @dataset.id})})
      @tweets = []
    end
    if @entities.length >= limit
      Entity.save_all(@entities.flatten.collect{|entity| entity.merge({:dataset_id => @dataset.id})})
      @entities = []
    end
    if @friendships.length >= limit
      Friendship.save_all(@friendships.collect{|friendship| friendship.merge({:dataset_id => @dataset.id})})
      @friendships = []
    end
  end

end
friendshipper = Friendshipper.new
friendshipper.username = "dgaff"
friendshipper.friendship([5])
