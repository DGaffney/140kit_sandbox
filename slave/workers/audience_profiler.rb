require './environment'
class AudienceProfiler < Instance
  
  attr_accessor :params, :dataset, :users, :tweets, :entities, :friendships, :user
  
  UPDATE_INTERVAL = 86400
  
  def initialize
    super
    self.instance_type = "audience_profiler"
    @users = []
    @tweets = []
    @entities = []
    @friendships = []
  end
  
  def profile
    puts "Audience Profiling..."
    check_in
    puts "Entering audience profiler routine."
    $instance = self
    loop do
      if !killed?
        profile_routine
      else
        puts "Just nappin'."
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def profile_routine
    select_dataset
    if !@dataset.nil?
      update_audience_data
      collect_audience_data
      finish_up
    else
      puts "No unlocked audience datasets found - will try again..."
    end
  end
  
  def select_dataset
    possible_datasets = Dataset.all(:scrape_type => "audience_profile", :order => [:updated_at.desc]).unlocked
    possible_datasets.each do |dataset|
      locked_dataset = dataset.lock
      (@dataset = locked_dataset; @user = Twit.user(@dataset.params.split(",").first); return @dataset )if !locked_dataset.nil?
    end
    @dataset = nil
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
  
  def collect_audience_data
    return nil if !@dataset.updated_at.nil?
    @user = User.new(TweetHelper.prep_user(Twit.user(@dataset.params.split(",").first)).merge({:dataset_id => @dataset.id}))
    @user.save! if User.first(:twitter_id => @user.twitter_id, :dataset_id => @dataset.id).nil?
    cursor = @dataset.params.include?(",") ? @dataset.params.split(",")[1].to_i : -1
    followers = nil
    begin
      followers = Twit.followers(@user.screen_name, :count => 100, :cursor => cursor)
    rescue
      retry
    end
    begin
      rate_limit_status = Twit.rate_limit_status
      sleep (Time.parse(rate_limit_status.reset_time)-Time.now)/rate_limit_status.remaining_hits
      followers = Twit.followers(@user.screen_name, :count => 100, :cursor => cursor)
    rescue
      retry
    end
    finished = false
    while !finished
      followers.users.each do |user|
        if !User.find(:screen_name => user.screen_name, :dataset_id => @dataset.id).nil?
          puts "Parsing #{user.screen_name}..."
          begin
            @friendships << {:followed_user_name => @user.screen_name, :followed_user_id => @user.id, :follower_user_name => user.screen_name, :follower_user_id => user.id}
            user_data = TweetHelper.prep_user(user)
            @users << user_data
            tweets_and_entities_from_user(user, nil, @dataset.params.split(",").last)
            friends = Twit.friends(user.screen_name, :count => 5000)
            if friends
              friends.users.collect{|friend| @friendships << {:followed_user_name => friend.screen_name, :followed_user_id => friend.id, :follower_user_name => user.screen_name, :follower_user_id => user.id, :created_at => Time.now}}
            end
            puts "Parsed #{user.screen_name}."
          rescue
            puts "401 on #{user.screen_name}."
            next
          end
        end
      end
      @dataset.params = "#{@user.screen_name},#{cursor},#{tweets_per_user}"
      @dataset.save!
      puts "#{@users.length} total users in memory."
      puts "#{@friendships.length} total friendships in memory."
      begin
        store_data
      rescue
        retry
      end
      cursor = followers.next_cursor
      finished = true if followers.next_cursor == 0
      begin
        followers = Twit.followers(@user.screen_name, :count => 5000, :cursor => cursor)
      rescue
        retry
      end
      begin
        rate_limit_status = Twit.rate_limit_status
        sleep (Time.parse(rate_limit_status.reset_time)-Time.now)/rate_limit_status.remaining_hits
        followers = Twit.followers(@user.screen_name, :count => 5000, :cursor => cursor)
      rescue
        retry
      end
    end
    begin
      store_data(1)
    rescue
      retry
    end
  end

  def tweets_and_entities_from_user(user, since_time=nil, tweets_per_user=200)
    store_data(1)
    page = 1
    raw_tweets = Twit.user_timeline(user.screen_name, :count => 200, :page => page, :include_entities => true, :include_rts => true)
    while !raw_tweets.empty? && @tweets.length <= tweets_per_user
      @tweets += raw_tweets.collect{|tweet| TweetHelper.prep_tweet(tweet)}
      @entities += raw_tweets.collect{|tweet| EntityHelper.prepped_entities(tweet)}
      return nil if !since_time.nil? && raw_tweets.last.created_at <= since_time
      page+=1
      raw_tweets = Twit.user_timeline(user.screen_name, :count => 200, :page => page, :include_entities => true, :include_rts => true)
    end
    return nil
  end

  def update_audience_data
    return nil if @dataset.updated_at.nil? || (Time.now-UPDATE_INTERVAL)<=@dataset.updated_at
    fresh_follower_ids = all_follower_ids
    current_follower_ids = Friendship.all(:fields => [:follower_user_id], :followed_user_name => @user.screen_name, :deleted_at => nil, :dataset_id => @dataset.id).collect{|friendship| friendship.follower_user_id}
    new_follower_ids = current_follower_ids-fresh_follower_ids
    stale_follower_ids = fresh_follower_ids-current_follower_ids
    sustained_follower_ids = fresh_follower_ids&current_follower_ids
    pull_clean_data(new_follower_ids)
    delete_friendships(stale_follower_ids)
    update_existing_data(sustained_follower_ids)
  end
  
  def pull_clean_data(follower_ids)
    follower_ids.each do |follower_id|
      user = Twit.user(follower_id)
      @users << TweetHelper.prep_user(user)
      tweets_and_entities_from_user(user, nil, 1)
      @friendships << {:followed_user_name => @user.screen_name, :followed_user_id => @user.id, :follower_user_name => user.screen_name, :follower_user_id => user.id, :created_at => Time.now}
    end
    begin
      store_data(1)
    rescue
      retry
    end
  end
  
  def delete_friendships(follower_ids)
    Friendship.all(:follower_user_id => follower_ids).update(:deleted_at => Time.now)
  end
  
  def update_existing_data(follower_ids)
    follower_ids.each do |follower_id|
      user = Twit.user(follower_id)
      tweets_and_entities_from_user(user, @dataset.updated_at, 1)
    end
    begin
      store_data(1)
    rescue
      retry
    end
  end
  
  def all_follower_ids
    all_follower_ids = []
    finished = false
    cursor = -1
    follower_ids = Twit.follower_ids(@dataset.params.split(",").first, :cursor => cursor)
    while !finished
      all_follower_ids += follower_ids.ids
      cursor = follower_ids.next_cursor
      follower_ids = Twit.follower_ids(@dataset.params.split(",").first, :cursor => cursor)
      finished = true if follower_ids.ids.length!=100
    end
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

audience_profiler = AudienceProfiler.new
audience_profiler.profile