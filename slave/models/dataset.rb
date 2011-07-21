class Dataset
  include DataMapper::Resource
  property :id, Serial
  property :scrape_type, String, :index => [:scrape_type]
  property :created_at, Time
  property :updated_at, Time
  property :scrape_finished, Boolean, :default => false
  property :instance_id, String, :index => [:instance_id]
  property :params, String
  property :tweets_count, Integer, :default => 0
  property :users_count, Integer, :default => 0
  property :entities_count, Integer, :default => 0
  has n, :tweets
  has n, :users
  has n, :curations, :through => Resource
  has 1, :importer_task
  
  def curation
    curations.first(:single_dataset => true)
  end
  
  def self.scrape_types
    ['track', 'follow', 'locations', 'import', 'audience_profile']
  end
  
  def self.valid_params(scrape_type, params)
    response = {}
    response[:reason] = ""
    response[:clean_params] = ""
    case scrape_type
    when "track"
      term = params
      response[:reason] = "The term must contain one letter or number" if term.scan(/\w/).flatten.empty?
      response[:reason] = "The term can't be empty" if term.scan(/\w/).flatten.empty?
      #break if !response[:reason].empty?
      response[:clean_params] = term
    when "follow"
      users = params.split(",")
      ids = []
      users.each do |user|
        user_id = Twit.user(user).id rescue 0
        ids << user_id if user_id != 0
        if user_id == 0
          response[:reason] = "No User found with name #{user}"
          return response
        end
      end
      response[:reason] = "The follow list contained no users" if ids.empty?
      response[:clean_params] = ids.join(",")
    when "locations"
      boundings = params.split(",").collect{|b| b.to_f}
      (response[:reason] = "Must input two pairs of numbers, separated by commas.";return response) if boundings.length!=4
      (response[:reason] = "Total Area of this box is zero - must make a real box";return response) if boundings.area==0
      (response[:reason] = "Latitudes cover more than one degree of area";return response) if (boundings[0]-boundings[2]).abs>1
      (response[:reason] = "Longitudes cover more than one degree of area";return response) if (boundings[1]-boundings[3]).abs>1
      (response[:reason] = "Latitudes are out of range (max 90 degrees)";return response) if boundings[0].abs>90 || boundings[2].abs>90
      (response[:reason] = "Longitudes are out of range (max 180 degrees)";return response) if boundings[1].abs>180 || boundings[3].abs>180
      #break if !response[:reason].empty?
      response[:clean_params] = boundings.join(",")
    when "import"
      if params.include?("140kit.com") || params.include?("twapperkeeper.com")
        self.resolve_raw_dataset_url(params)
      else
        if !File.exists?(params)
          response[:reason] = "File does not exist locally"
        end
      end
      response[:clean_params] = params if response[:reason].blank?
    when "audience_profile"
      user_id = Twit.user(params).id rescue 0
      if user_id == 0
        response[:reason] = "No User found with name #{params}"
        return response
      end
      response[:reason] = "The audience profile list contained no users" if params.empty?
      response[:clean_params] = params
    end
    return response
  end
  
  def self.resolve_raw_dataset_url(params)
    #here we would want to figure out the machine/id of the dataset, touch the file, verify that it exists, and then run against that url as the params.
    if params.include?("140kit.com")
      return params
    elsif params.include?("twapperkeeper.com")
      return params
    end
  end
  
  def full_delete
    Tweet.all(:dataset_id => self.id).destroy
    Entity.all(:dataset_id => self.id).destroy
    User.all(:dataset_id => self.id).destroy
    Friendship.all(:dataset_id => self.id).destroy
    ImporterTask.all(:dataset_id => self.id).destroy
    self.destroy
  end
end