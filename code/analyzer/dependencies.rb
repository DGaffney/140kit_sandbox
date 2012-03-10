module Analysis::Dependencies
  def self.method_missing(method_name, *args)
    analytical_offering_functions = AnalyticalOffering.all(:language => "ruby").collect{|ao| ao.function}
    if analytical_offering_functions.include?(method_name.to_s)
      if self.respond_to?(method_name.to_s+"_dependencies")
        dependencies = Analysis::Dependencies.send(method_name.to_s+"_dependencies")
        dependencies.each do |dependency|
          require dependency
        end
        puts "Required #{dependencies.length} dependencies:"
        puts dependencies.join(", ")
        return dependencies
      else
        return "No dependencies defined."
      end
    else
      super
    end
  end

  def self.bitly_api_chart_dependencies
    ['open-uri', 'nokogiri', 'json']
  end

  def self.click_tweet_count_comparison_dependencies
    ['csv']
  end  

  def self.centrality_differentials_dependencies
    ['csv']
  end  

  def self.jaccard_to_csv_dependencies
    ['csv']
  end

  def self.raw_csv_dependencies
    ['csv']
  end
  
  def self.advanced_histogram_dependencies
    ['csv']
  end

  def self.advanced_histogram_a_dependencies
    ['csv']
  end

  def self.advanced_histogram_b_dependencies
    ['csv']
  end

  def self.advanced_histogram_c_dependencies
    ['csv']
  end

  def self.basic_histogram_dependencies
    ['csv']
  end

  def self.size_counter_dependencies
    ['csv']
  end
  
  def self.time_based_summary_dependencies
    ['csv']
  end
  
  def self.word_frequency_dependencies
    ['csv']
  end
  
  def self.csv_export_dependencies
    ['csv']
  end  
end
