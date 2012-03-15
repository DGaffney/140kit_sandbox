load File.dirname(__FILE__)+'/../environment.rb'
class Filter < Instance

  MAX_TRACK_IDS = 10000
  BATCH_SIZE = 100
  STREAM_API_URL = "http://stream.twitter.com"
  CHECK_FOR_NEW_DATASETS_INTERVAL = 60*5
  attr_accessor :user_account, :username, :password, :next_dataset_ends, :queue, :params, :datasets, :start_time, :last_start_time, :scrape_type

  def initialize
    super
    @datasets = []
    @queue = []
    @start_time = Time.now
    @scrape_type = ARGV[0] || "track"
    at_exit { do_at_exit }
  end
  
  def do_at_exit
    puts "Exiting."
    save_queue(@queue)
    @user_account.unlock
    @datasets.collect{|dataset| dataset.unlock}
  end
  
  def filt
    puts "Filtering..."
    check_in
    assign_user_account
    TweetStream.configure do |config|
      config.username = @screen_name
      config.password = @password
      config.auth_method = :basic
      config.parser = :yajl
    end
    puts "Entering filter routine."
    loop do
      if !killed?
        stream_routine
      else
        puts "Just nappin'."
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def stream_routine
    add_datasets
    clean_up_datasets
    if !@datasets.empty?
      update_next_dataset_ends
      update_params
      collect
      save_queue(@queue)
      clean_up_datasets
    end
  end
  
  def assign_user_account
    puts "Assigning user account."
    message = true
    while @screen_name.nil?
      user = AuthUser.unlocked.first
      if !user.nil? && user.lock
        @user_account = user
        @screen_name = user.screen_name
        @password = user.password
        puts "Assigned #{@screen_name}."
      else
        answer = Sh::clean_gets_yes_no("No twitter accounts available. Add one now?") if message
        if answer
          first_attempt = true
          while answer!="y" || first_attempt
            first_attempt = false
            puts "Enter your screen name:"
            screen_name = Sh::clean_gets
            puts "Enter your password:"
            password = Sh::clean_gets
            puts "We got the username '#{screen_name}' and a password that was #{password.length} characters long. Sound right-ish? (y/n)"
            answer = Sh::clean_gets
          end
          puts "Creating new AuthUser..."
          user = AuthUser.new(:screen_name => screen_name, :password => password)
          user.save
          user = AuthUser.unlocked.first
          @user_account = user
          @screen_name = user.screen_name
          @password = user.password
          TweetStream.configure do |config|
            config.screen_name = @screen_name
            config.password = @password
            config.auth_method = :basic
            config.parser   = :yajl
          end
          puts "Assigned #{@screen_name}."
        else
          puts "Then I can't do anything for you. May god have mercy on your data"
          exit!
        end
        message = false
      end
      sleep(5)
    end
  end
  
  def collect
    puts "Collecting: #{params_for_stream.inspect}"
    client = TweetStream::Client.new
    client.on_interval(CHECK_FOR_NEW_DATASETS_INTERVAL) { 
      time = @start_time
      datasets = @datasets
      Thread.new do
        rsync_previous_files(datasets, time)
      end
      @start_time = Time.now
      puts "Switching to new files..."
      client.stop if add_datasets 
    }
    client.on_limit { |skip_count| puts "\nWe are being rate limited! We lost #{skip_count} tweets!\n" }
    client.on_error { |message| puts "\nError: #{message}\n";client.stop }
    client.filter(params_for_stream) do |tweet|
      # puts "[tweet] #{tweet[:user][:screen_name]}: #{tweet[:text]}"
      print "."
      @queue << tweet
      if @queue.length >= BATCH_SIZE
        tmp_queue = @queue
        @queue = []
        Thread.new do
          save_queue(tmp_queue)
        end
      end
    end
  end
  
  def params_for_stream
    params = {}
    @params.each {|k,v| params[k.to_sym] = v.collect {|x| x[:params] } }
    return params
  end
  
  def save_queue(tmp_queue)
    if !tmp_queue.empty?
      print "|"
      tweets, users, entities, geos, coordinates = data_from_queue(tmp_queue)
      dataset_ids = tweets.collect{|t| t[:dataset_id]}.uniq
      dataset_ids.each do |dataset_id|
        dataset = Dataset.first(:id => dataset_id)
        Tweet.store_to_flat_file(tweets.select{|t| t[:dataset_id] == dataset_id}, dir(Tweet, dataset_id, @start_time))
        dataset.tweets_count+=tweets.select{|t| t[:dataset_id]==dataset_id}.count
        User.store_to_flat_file(users.select{|u| u[:dataset_id] == dataset_id}, dir(User, dataset_id, @start_time))
        dataset.users_count+=users.select{|t| t[:dataset_id]==dataset_id}.count
        Entity.store_to_flat_file(entities.select{|e| e[:dataset_id] == dataset_id}, dir(Entity, dataset_id, @start_time))
        dataset.entities_count+=entities.select{|t| t[:dataset_id]==dataset_id}.count
        Geo.store_to_flat_file(geos.select{|g| g[:dataset_id] == dataset_id}, dir(Geo, dataset_id, @start_time))
        Coordinate.store_to_flat_file(coordinates.select{|c| c[:dataset_id] == dataset_id}, dir(Coordinate, dataset_id, @start_time))
        dataset.save
      end
    end
  end
  
  def dir(model, dataset_id, time)
    return "#{ENV["TMP_PATH"]}/#{model}/#{dataset_id}_#{time.strftime("%Y-%m-%d_%H-%M-%S")}"
  end
  
  def rsync_previous_files(datasets, time)
    [Tweet, User, Entity, Geo, Coordinate].each do |model|
      datasets.each do |dataset| 
        Sh::mkdir("#{STORAGE["path"]}/#{model}")
        Sh::store_to_disk("#{dir(model, dataset.id, time)}.tsv", "#{model}/#{dataset.id}_#{time.strftime("%Y-%m-%d_%H-%M-%S")}.tsv")
        Sh::bt "rm #{dir(model, dataset.id, time)}.tsv"
      end
    end
  end

  def data_from_queue(tmp_queue)
    tweets = []
    users = []
    entities = []
    geos = []
    coordinates = []
    tmp_queue.each do |json|
      tweet, user = TweetHelper.prepped_tweet_and_user(json)
      geo = GeoHelper.prepped_geo(json)
      dataset_ids = determine_datasets(json)
      tweets      = tweets+dataset_ids.collect{|dataset_id| tweet.merge({:dataset_id => dataset_id})}
      users       = users+dataset_ids.collect{|dataset_id| user.merge({:dataset_id => dataset_id})}
      geos        = geos+dataset_ids.collect{|dataset_id| geo.merge({:dataset_id => dataset_id})}
      coordinates = coordinates+CoordinateHelper.prepped_coordinates(json).collect{|coordinate| dataset_ids.collect{|dataset_id| coordinate.merge({:dataset_id => dataset_id})}}.flatten
      entities    = entities+EntityHelper.prepped_entities(json).collect{|entity| dataset_ids.collect{|dataset_id| entity.merge({:dataset_id => dataset_id})}}.flatten
    end
    return tweets, users, entities, geos, coordinates
  end
  
  def update_params
    @params = {}
    for d in @datasets
      if @params[d.scrape_type]
        if d.scrape_type == "locations"
          @params[d.scrape_type] << {:params => d.params.split(",")[0..d.params.split(",").length-2].join(","), :dataset_id => d.id}
        else
          @params[d.scrape_type] << {:params => d.params.split(",").first, :dataset_id => d.id}
        end
      else
        if d.scrape_type == "locations"
          @params[d.scrape_type] = [{:params => d.params.split(",")[0..d.params.split(",").length-2].join(","), :dataset_id => d.id}]
        else
          @params[d.scrape_type] = [{:params => d.params.split(",").first, :dataset_id => d.id}]
        end
      end
    end
  end
  
  def determine_datasets(tweet)
    return [@datasets.first.id] if @datasets.length == 1
    valid_datasets = []
    params.each_pair do |method, values|
      if method == "locations"
        values.each do |value|
          valid_datasets << value[:dataset_id] if any_in_location?(value[:params], tweet)
        end
      elsif method == "track"
        values.each do |value|
          if value[:params].include?(" ")
            valid_datasets << value[:dataset_id] if tweet[:text].include?(value[:params]) #add .downcase to set case sensitivity off...
          else
            valid_datasets << value[:dataset_id] if tweet[:text].split(/[~!$%^&* \[\]\(\)\{\}\-=_+.,\/<>?:;"']/).include?(value[:params])
          end
        end
      elsif method == "follow"
        values.each do |value|
          valid_datasets << value[:dataset_id] if tweet[:user][:id] == value[:params].to_i
        end
      end
    end
    return valid_datasets
  end
  
  def any_in_location?(location, tweet)
    coords = CoordinateHelper.prepped_coordinates(tweet)
    found = false
    coords.each do |coord|
      found = true if in_location?(location, coord[:lat], coord[:lon])
      break if found
    end
    return found
  end

  def in_location?(location_params, lat, lon)
    search_location = location_params.split(",").map {|c| c.to_i }
    l_lon_range = (search_location[0]..search_location[2])
    l_lat_range = (search_location[1]..search_location[3])
    return (l_lon_range.include?(lon) && l_lat_range.include?(lat))
  end
  
  def add_datasets
    datasets = Dataset.unlocked.all(:scrape_finished => false, :scrape_type => @scrape_type, :instance_id.not => "system")
    return claim_new_datasets(datasets)
  end

  def claim_new_datasets(datasets)
    # distribute datasets evenly
    return false if datasets.empty?
    num_instances = Instance.count(:instance_type => "streamer", :killed => false)
    datasets_per_instance = num_instances.zero? ? datasets.length : (datasets.length.to_f / num_instances.to_f).ceil
    datasets_to_claim = datasets[0..datasets_per_instance]
    if !datasets_to_claim.empty?
     claimed_datasets = Dataset.lock(datasets_to_claim)
     if !claimed_datasets.empty?
       claimed_datasets.each do |dataset|
         dataset.storage_machine_id = Machine.first(:hostname => STORAGE["hostname"]).id rescue 0
       end
       update_datasets(claimed_datasets)
       return true
     end
    end
    return false
  end
   
  def update_datasets(datasets)
    @datasets = @datasets|datasets
    if @datasets.length > MAX_TRACK_IDS
      denied_datasets = []
      @datasets -= (denied_datasets = @datasets[MAX_TRACK_IDS-1..datasets.length])
      unlock(denied_datasets)
    end
  end

  def update_next_dataset_ends
    update_start_times
    refresh_datasets # this is absolutely necessary even while it's called in update_start_times above. huh!
    soonest_ending_dataset = @datasets.select{|d| d.params.split(",").last.to_i!=-1}.sort {|x,y| (x.created_at.to_time.gmt + x.params.split(",").last.to_i - DateTime.now.to_time.gmt) <=> (y.created_at.to_time.gmt + y.params.split(",").last.to_i - DateTime.now.to_time.gmt) }.first
    @next_dataset_ends = soonest_ending_dataset.created_at.to_time.gmt + soonest_ending_dataset.params.split(",").last.to_i rescue nil
  end

  def update_start_times
    refresh_datasets
    datasets_to_be_started = @datasets.select {|d| d.created_at.nil? }
    # Dataset.update_all({:created_at => DateTime.now.in_time_zone}, {:id => datasets_to_be_started.collect {|d| d.id}})
    Dataset.all(:id => datasets_to_be_started.collect {|d| d.id}).update(:created_at => Time.now)
    refresh_datasets
  end

  def refresh_datasets
    @datasets = Dataset.all(:id => @datasets.collect {|d| d.id })
  end

  def clean_up_datasets
    started_datasets = @datasets.reject {|d| d.created_at.nil? }
    finished_datasets = started_datasets.select{|d| d.params.split(",").last.to_i!=-1}.select {|d| U.times_up?(d.created_at.gmt+d.params.split(",").last.to_i) }
    if !finished_datasets.empty?
      puts "Finished collecting "+finished_datasets.collect {|d| "#{d.scrape_type}:\"#{d.internal_params_label}\"" }.join(", ")
      # Dataset.update_all({:scrape_finished => true}, {:id => finished_datasets.collect {|d| d.id}})
      Dataset.all(:id => finished_datasets.collect {|d| d.id}).update(:scrape_finished => true, :status => "tsv_stored")
      @datasets -= finished_datasets
      finished_datasets.collect{|dataset| dataset.unlock}
    end
  end
  
end

filter = Filter.new
filter.username = "dgaff"
filter.filt