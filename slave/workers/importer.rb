require './environment'
class Importer < Instance
  
  BATCH_SIZE = 100000
  
  attr_accessor :queue, :importer_task, :dataset
  
  def initialize
    super
    self.instance_type = "importer"
    @queue = []
    @file_information = {}
    at_exit { do_at_exit }
  end

  def import(to_location=".")
    puts "Importing..."
    check_in
    $instance = self
    loop do
      puts "Assigning Importer Task..."
      @importer_task = ImporterTask.unlocked.first(:finished => false)
      while @importer_task.nil?
        puts "Found no unlocked Importer tasks!"
        @importer_task = ImporterTask.unlocked.first(:finished => false)
      end
      @importer_task.lock
      @dataset = @importer_task.dataset
      @importer_task.import(self)
      finalize_dataset_info
    end
  end

  def import_file_json(file)
    tweet_keys = Tweet.attributes.collect{|a| a.to_s}.sort-["id"]
    user_keys = User.attributes.collect{|a| a.to_s}.sort-["id"]
    entity_keys = Entity.attributes.collect{|a| a.to_s}.sort-["id"]
    file_data = File.open(file, "r")
    @file_information = {:tweets => {:path => ENV['TMP_PATH'], :name => "/"+Tweet.storage_name+".tsv"}, :users => {:path => ENV['TMP_PATH'], :name => "/"+User.storage_name+".tsv"}, :entities => {:path => ENV['TMP_PATH'], :name => "/"+Entity.storage_name+".tsv"}}
    tweet_file = FasterCSV.open(@file_information[:tweets][:path]+@file_information[:tweets][:name], "a+", :col_sep => "\t")
    user_file = FasterCSV.open(@file_information[:users][:path]+@file_information[:users][:name], "a+", :col_sep => "\t")
    entity_file = FasterCSV.open(@file_information[:entities][:path]+@file_information[:entities][:name], "a+", :col_sep => "\t")
    count = 0
    file_data.each_line do |json|
      count+=1
      hash = JSON.parse(json)
      if valid_tweet_data(hash)
        tweet = TweetHelper.prep_tweet(hash.dup)
        user = TweetHelper.prep_user(hash.dup["user"])
        entities = EntityHelper.prepped_entities(hash.dup["entities"])
        # tweet_file << tweet_keys.collect{|k| Tweet.quote_value_full(tweet[k])}
        # user_file << user_keys.collect{|k| User.quote_value_full(user[k])}
        # entities.each do |entity|
        #   entity_file << entity_keys.collect{|k| Entity.quote_value_full(entity[k])}
        # end          
      end
      puts count
    end
    Tweet.send_tsv_infile
    User.send_tsv_infile
    Entity.send_tsv_infile
    Sh::remove(file)
  end

  def save_queue
    if !@queue.empty?
      puts "Saving #{@queue.length} tweets."
      tweets, users, entities = tweets_and_users_and_entities_from_queue
      @queue = []
      Thread.new { Tweet.store_to_tsv(tweets); User.store_to_tsv(users); Entity.store_to_tsv(entities) }
    end    
  end
  
  def tweets_and_users_and_entities_from_queue
    tweets = []
    users = []
    entities = []
    @queue.each do |hash|
      if valid_tweet_data(hash)
        entities_data = hash["entities"]
        tweet, user = TweetHelper.prepped_tweet_and_user(hash)
        tweets << tweet.merge({"dataset_id" => @dataset.id})
        users << user.merge({"dataset_id" => @dataset.id})
        entities = entities+EntityHelper.prepped_entities(entities_data).collect{|entity| entity.merge({:dataset_id => @dataset.id})}
      end
    end
    return tweets, users, entities
  end

  def finalize_dataset_info
    dataset = @importer_task.dataset
    dataset.tweets_count = Tweet.count(:dataset_id => dataset.id)
    dataset.users_count = User.count(:dataset_id => dataset.id)
    dataset.start_time = Tweet.first(:dataset_id => dataset.id).created_at
    dataset.length = Tweet.last(:dataset_id => dataset.id).created_at-dataset.start_time
    dataset.save!
    @importer_task.finished = true
    @importer_task.save!
    @importer_task.unlock
    @importer_task = nil
  end
  
  def valid_tweet_data(hash)
    valid = true
    valid = false if hash.keys.length == 1 && hash.keys.first == "delete"
    valid = false if hash.keys.length == 1 && hash.keys.first == "scrub_geo"
    valid = false if hash.keys.length == 1 && hash.keys.first == "limit"
    return valid
  end
  
  def do_at_exit
    puts "Exiting."
    Lock.all_owned_by_me.collect{|lock| lock.destroy}
    self.destroy
  end

end

importer = Importer.new
importer.import