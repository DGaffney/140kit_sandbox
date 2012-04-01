class Curation < ActiveRecord::Base
  belongs_to :researcher
  has_and_belongs_to_many :datasets, :join_table => "curation_datasets"
  has_many :analysis_metadatas
  has_many :graphs
  
  def tweets_count
    return datasets.collect{|d| d.tweets_count}.sum
  end
  
  def entities_count
    return datasets.collect{|d| d.entities_count}.sum
  end

  def users_count
    return datasets.collect{|d| d.users_count}.sum
  end
  
  def self.max_time
    return 1.week
  end
  
  def self.default_time_series
    return 5.minutes
  end
  
  def self.default_step
    return 10.minutes
  end
  
  def current_status(current_user=nil)
    case self.status
    when "tsv_storing"
      return "Collecting"
    when "tsv_stored"
      return "Finishing collection"
    when "needs_import"
      return "Ready for analysis"
    when "imported"
      return "Live"
    when "needs_drop"
      return "Dropping"
    when "dropped"
      return "Archived"
    when "zero_data"
      return "No Tweets Found!"
    else
      return "Unknown"
    end
  end
  
  def current_options(current_user=nil)
    #this is bad design, I know. It's just the first thing I thought of that could do this - problem is I'm not sure you can access a specific object from within model?
    case self.status
    when "tsv_storing"
      if self.tweets_count == 0
        return "No Tweets Yet"
      else
        return "<a href='/datasets/#{self.id}/analyze'>Set Analytics</a>"
      end
    when "tsv_stored"
      if self.tweets_count == 0
        return "No Tweets"
      else
        return "<a href='/datasets/#{self.id}/analyze'>Set Analytics</a> | <a href='/datasets/#{self.id}/import'>Bring it live</a>"
      end
    when "needs_import"
      return "Sit tight..."
    when "imported"
      if self.tweets_count == 0
        return "No Tweets"
      else
        return "<a href='/datasets/#{self.id}/analyze'>Set Analytics</a>"
      end
    when "needs_drop"
      return "Sit tight..."
    when "dropped"
      if self.tweets_count == 0
        return "No Tweets"
      else
        return "<a href='/datasets/#{self.id}/analyze'>Set Analytics</a> | <a href='/datasets/#{self.id}/import'>Restore</a>"
      end
    when "zero_data"
      if self.researcher_id == current_user.id
        return "No Tweets Found! <a href='/datasets/#{self.id}/destroy'>Remove</a>"
      else
        return "No Tweets Found!"
      end
    else
      return "Sit tight..."
    end
  end
  
end
