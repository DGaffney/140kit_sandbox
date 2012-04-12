class Dataset < ActiveRecord::Base
  has_and_belongs_to_many :curations, :join_table => "curation_datasets"
  
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  
  
  def friendly_type
    case self.scrape_type
    when "locations"
      return "Bounding Box"
    when "track"
      return "Streaming Term"
    when "track"
      return "User Stream"
    end
  end
  
  def friendly_parameters
    case self.scrape_type
    when "locations"
      params = self.params.split(",")[0..3]
      timed_seconds = distance_of_time_in_words(self.seconds, 0, true)
      return "Bounding Box Parameters: #{params}<br /> Length: #{timed_seconds} (#{number_with_delimiter(self.seconds)} seconds)"
    when "track"
      params = self.params.split(",")
      timed_seconds = distance_of_time_in_words(self.seconds, 0, true)
      return "Term: #{params.first}<br /> Length: #{timed_seconds} (#{number_with_delimiter(self.seconds)} seconds)"
    when "follow"
      params = self.params.split(",")
      timed_seconds = distance_of_time_in_words(self.seconds, 0, true)
      return "User: #{params[1]}<br /> Length: #{timed_seconds} (#{number_with_delimiter(self.seconds)} seconds)"
    end
  end
  
  def end_time
    case self.scrape_type
    when "locations"
      return self.created_at+self.seconds
    when "track"
      return self.created_at+self.seconds
    when "follow"
      return self.created_at+self.seconds
    end
  end
  
  def seconds
    case self.scrape_type
    when "locations"
      return self.params.split(",").last.to_i
    when "track"
      return self.params.split(",").last.to_i
    when "follow"
      return self.params.split(",").last.to_i
    end
  end
end
