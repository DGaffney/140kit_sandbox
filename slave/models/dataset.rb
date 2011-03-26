class Dataset
  include DataMapper::Resource
  property :id, Serial
  property :scrape_type, String, :index => [:scrape_type]
  property :start_time, Time
  property :length, Integer
  property :created_at, Time
  property :updated_at, Time
  property :scrape_finished, Boolean, :default => false
  property :instance_id, String, :index => [:instance_id]
  property :params, String
  property :tweets_count, Integer, :default => 0
  property :users_count, Integer, :default => 0
  has n, :tweets
  has n, :users
  has n, :curations, :through => Resource
  
  def self.scrape_types
    ['track', 'follow', 'locations']
  end
  
  def self.valid_params(scrape_type, params)
    response = {}
    response[:reason] = ""
    response[:clean_params] = nil
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
          break
        end
      end
      response[:clean_params] = ids.join(",")
    when "locations"
      boundings = params.split(",").collect{|b| b.to_f}
      response[:reason] = "Must input two pairs of numbers, separated by commas." if boundings.length!=4
      response[:reason] = "Latitudes cover more than one degree of area" if (boundings[0]-boundings[2]).abs>1
      response[:reason] = "Longitudes cover more than one degree of area" if (boundings[1]-boundings[3]).abs>1
      response[:reason] = "Latitudes are out of range (max 90 degrees)" if boundings[0].abs>90 || boundings[2].abs>90
      response[:reason] = "Longitudes are out of range (max 180 degrees)" if boundings[1].abs>180 || boundings[3].abs>180
      #break if !response[:reason].empty?
      response[:clean_params] = boundings.join(",")
    end
    return response
  end
end