class Dataset < ActiveRecord::Base
  has_and_belongs_to_many :curations, :join_table => "curation_datasets"
  
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  
  
  def friendly_type
    case self.scrape_type
    when "track"
      return "Streaming Term"
    end
  end
  
  def friendly_parameters
    case self.scrape_type
    when "track"
      params = self.params.split(",")
      timed_seconds = distance_of_time_in_words(self.seconds, 0, true)
      return "Term: #{params.first}<br /> Length: #{timed_seconds} (#{number_with_delimiter(self.seconds)} seconds)"
    end
  end
  
  def end_time
    case self.scrape_type
    when "track"
      return self.created_at+self.seconds
    end
  end
  
  def seconds
    case self.scrape_type
    when "track"
      return self.params.split(",").last.to_i
    end
  end
end
