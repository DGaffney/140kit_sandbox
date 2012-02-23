load File.dirname(__FILE__)+'/../environment.rb'
class Hashtagger < Instance

  BATCH_SIZE = 1000
  HASHTAG_CHECK_INTERVAL = 600
  SLEEP_CONSTANT = 1
  attr_accessor :api_key, :woeids, :hashtags, :start_time, :woeid_statuses, :recently_finished, :topics_to_update, :topics_to_save, :last_csv_write

  def initialize
    super
    @hashtags = []
    @recently_finished = []
    yahoo_settings = YAML.load(File.read(File.dirname(__FILE__)+'/../config/api_keys.yml'))
    @api_key = yahoo_settings["yahoo"]["consumer_secret"]
    oauth_settings = YAML.load(File.read(File.dirname(__FILE__)+'/../config/twitter.yml'))
    account = "dgaff"
    Twit.consumer_key = oauth_settings[account]["oauth_settings"]["consumer_key"]
    Twit.consumer_secret = oauth_settings[account]["oauth_settings"]["consumer_secret"]
    Twit.oauth_token = oauth_settings[account]["access_token"]["access_token"]
    Twit.oauth_token_secret = oauth_settings[account]["access_token"]["access_token_secret"]
    @start_time = Time.now
    @last_csv_write = Time.now-7200
    @topics_to_update = []
    @topics_to_save = []
    @woeid_statuses = {}
    at_exit { do_at_exit }
  end
  
  def do_at_exit
    puts "Exiting."
    save_queue
    @user_account.unlock
    @datasets.collect{|dataset| dataset.unlock}
  end
  
  def hashtag
    puts "Hashtagging..."
    check_in
    puts "Entering hashtag routine."
    loop do
      if !killed?
        topic_routine
      else
        puts "Just nappin'."
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def topic_routine
    collect_all_locations
    pull_current_trending_topics
    export_finished_to_csv if Time.now.to_i-@last_csv_write.to_i >= 3600
  end
  
  def collect_all_locations
    current_locations = Location.all
    current_woeids = current_locations.collect{|x| x.woeid}
    twitter_locations = []
    begin
      twitter_locations = Twit.trend_locations
    rescue
      retry
    end
    new_locations = []
    twitter_locations.each do |twitter_location|
      if !current_woeids.include?(twitter_location.woeid)
        l = Location.new(:woeid => twitter_location.woeid, :name => twitter_location.name, :parent_id => twitter_location.parentid, :place_code => twitter_location.placeType.code, :place_code_name => twitter_location.placeType.name, :country => twitter_location.country, :country_code => twitter_location.countryCode)
        l.save!
        current_locations << l
      end
    end
    @woeids = current_locations.collect{|l| l.woeid}
  end
  
  def pull_current_trending_topics
    run_time = Time.now
    @woeids.each do |woeid|
      # begin
        puts "Now running trending topics pull for woeid of #{woeid}... (#{@topics_to_update.length} to update, #{@topics_to_save.length} to save)"
        @woeid_statuses[woeid] = {} if @woeid_statuses[woeid].nil?
        current_topics = @woeid_statuses[woeid]["current_topics"] || TrendingTopic.all(:ended_at => nil, :woeid => woeid).collect{|x| x.name}
        latest_topics = Twit.local_trends(woeid)
        ended_topics = current_topics-latest_topics
        new_topics = latest_topics-current_topics
        ended_trending_topics = TrendingTopic.all(:ended_at => nil, :woeid => woeid, :name => ended_topics)
        ended_trending_topics.collect{|tt| tt.ended_at = run_time}
        @topics_to_update += ended_trending_topics
        new_trending_topics = new_topics.collect{|name| TrendingTopic.new(:created_at => run_time, :name => name, :woeid => woeid, :ended_at => nil)}
        @topics_to_save += new_trending_topics
        @woeid_statuses[woeid]["last_run"] = Time.now
        @woeid_statuses[woeid]["current_topics"] = latest_topics
        puts "Finished running trending topics pull for woeid of #{woeid}."
      # rescue
      #   retry
      # end
    end
    TrendingTopic.update_all(@topics_to_update)
    dir = lambda{|model| File.dirname(__FILE__)+'/../../../data/raw/'+model+"/"+@start_time.strftime("%Y-%m-%d_%H-%M-%S")}
    TrendingTopic.store_to_flat_file(@topics_to_update.collect{|x| x.attributes}, dir.call("trending_topic"))
    @topics_to_update = []
    TrendingTopic.save_all(@topics_to_save)
    @topics_to_save = []
    while @woeid_statuses.values.collect{|k| k["last_run"]}.sort{|x,y| x.to_i<=>y.to_i}.first+HASHTAG_CHECK_INTERVAL<Time.now
      sleep(1)
    end
  end
  
  def export_finished_to_csv
    debugger
    dir = lambda{|model| File.dirname(__FILE__)+'/../../../data/raw/'+model+"/"+@start_time.strftime("%Y-%m-%d_%H-%M-%S")}
    rsync_job = fork do
      `rsync #{dir.call('trending_topic')}.tsv gonkclub@nutmegunit.com:oii/raw_data/trending_topic/#{@start_time.strftime("%Y-%m-%d_%H-%M-%S")}.tsv`
      `rm #{dir.call('trending_topic')}.tsv`
    end
    Process.detach(rsync_job)
    @start_time = Time.now
    `mkdir -p #{dir.call('trending_topic').split("/")[0..dir.call('trending_topic').split("/").length-2].join("/")}`
  end
  
  def save_queue
    TrendingTopic.update_all(@topics_to_update)
    dir = lambda{|model| File.dirname(__FILE__)+'/../../../data/raw/'+model+"/"+@start_time.strftime("%Y-%m-%d_%H-%M-%S")}
    TrendingTopic.store_to_flat_file(@topics_to_update.collect{|x| x.attributes}, dir.call("trending_topic"))
    @topics_to_update = []
    TrendingTopic.save_all(@topics_to_save)
    @topics_to_save = []    
  end
end

hashtagger = Hashtagger.new
hashtagger.hashtag
