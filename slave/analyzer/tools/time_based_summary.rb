class TimeBasedSummary < AnalysisMetadata

  def self.verify_variable(metadata, analytical_offering_variable, answer)
    case analytical_offering_variable.name
    when "granularity"
      valid_responses = ["year", "month", "date", "hour"]
      response = {}
      response[:reason] = "You may only choose one of these options, and only these options (can't be left blank). You entered: #{answer}. You can choose from ['year','month','date','hour']."
      response[:variable] = answer
      return response if !valid_responses.include?(answer)
    end
    return {:variable => answer}
  end
  
  def self.set_variables(analysis_metadata, analytical_offering_variable, curation)
    case analytical_offering_variable.function
    when "granularity"
      return "date"
    end
  end
  
  def self.run(curation_id, granularity)
    curation = Curation.first({:id => curation_id})
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    time_queries = self.resolve_time_query(granularity)
    time_queries.each_pair do |time_granularity,time_query|
      user_timeline = nil
      tweet_timeline = nil
      #this ugliness is necessary as datamapper does not currently support native integration of big weird group by's that use sql functions
      case DataMapper.repository.adapter.options["adapter"]
      when "mysql"
        user_timeline = DataMapper.repository.adapter.select("select date_format(created_at, '#{time_query}') as created_at from users where"+Analysis.conditions_to_mysql_query(conditional)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
        tweet_timeline = DataMapper.repository.adapter.select("select date_format(created_at, '#{time_query}') as created_at from tweets where"+Analysis.conditions_to_mysql_query(conditional)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
      when "sqlite3"
        user_timeline = DataMapper.repository.adapter.select("select strftime('#{time_query}', created_at) as created_at from users where"+Analysis.conditions_to_mysql_query(conditional)+"group by strftime('#{time_query}', created_at) order by created_at desc")
        tweet_timeline = DataMapper.repository.adapter.select("select strftime('#{time_query}', created_at) as created_at from tweets where"+Analysis.conditions_to_mysql_query(conditional)+"group by strftime('#{time_query}', created_at) order by created_at desc")
      end
      self.time_based_analytics("tweets", time_query, tweet_timeline, curation, time_granularity, save_path)
      self.time_based_analytics("users", time_query, user_timeline, curation, time_granularity, save_path)
    end
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.resolve_time_query(time_granularity)
    case DataMapper.repository.adapter.options["adapter"]
    when "mysql"
      case time_granularity
      when "year"
        return {"year" => "%Y"}
      when "month"
        return {"year" => "%Y", "month" => "%Y-%m"}
      when "date"
        return {"year" => "%Y", "month" => "%Y-%m", "date" => "%Y-%m-%e"}
      when "hour"
        return {"year" => "%Y", "month" => "%Y-%m", "date" => "%Y-%m-%e", "hour" => "%Y-%m-%e %H"}
      end
    when "sqlite3"
      case time_granularity
      when "year"
        return {"year" => "%Y"}
      when "month"
        return {"year" => "%Y", "month" => "%Y-%m"}
      when "date"
        return {"year" => "%Y", "month" => "%Y-%m", "date" => "%Y-%m-%d"}
      when "hour"
        return {"year" => "%Y", "month" => "%Y-%m", "date" => "%Y-%m-%d", "hour" => "%Y-%m-%d %H"}
      end
    end
  end

  def self.time_based_analytics(model, time_query, timeline, curation, granularity, save_path)
    timeline.each do |time|
      time_slice, year, month, date, hour = self.resolve_time(granularity, time)
      graphs = []
      graph_points = []
      conditional = Analysis.curation_conditional(curation).merge(Analysis.time_conditional("created_at", time, granularity))
      totals_hash = {}
      general_frequency_set_conditions = {
        :model => model.to_class, 
        :conditional => conditional, 
        :style => "histogram", 
        :analysis_metadata_id => self.analysis_metadata.id,
        :time_slice => time_slice, 
        :granularity => granularity, 
        :year => year, 
        :month => month, 
        :date => date, 
        :hour => hour
      }
      case model
      when "tweets"
        basic_histogram_frequency_sets = [
          {:attribute => :language},
          {:attribute => :created_at},
          {:attribute => :source},
          {:attribute => :location}
        ].collect{|fs| fs.merge(general_frequency_set_conditions)}
        BasicHistogram.generate_graphs(basic_histogram_frequency_sets, curation)
        BasicHistogram.generate_graphs([
          {:title => "urls", :frequency_type => "urls", :style => "word_frequencies", :time_slice => time_slice, :granularity => granularity, :year => year, :month => month, :date => date, :hour => hour, :analysis_metadata_id => self.analysis_metadata.id}, 
          {:title => "hashtags", :frequency_type => "hashtags", :style => "word_frequencies", :time_slice => time_slice, :granularity => granularity, :year => year, :month => month, :date => date, :hour => hour, :analysis_metadata_id => self.analysis_metadata.id}, 
          {:title => "user_mentions", :frequency_type => "user_mentions", :style => "word_frequencies", :time_slice => time_slice, :granularity => granularity, :year => year, :month => month, :date => date, :hour => hour, :analysis_metadata_id => self.analysis_metadata.id}
        ], curation) do |fs, graph, conditional|
          WordFrequency.generate_word_frequencies_from_entities(fs, graph, conditional)
        end
      when "users"
        basic_histogram_frequency_sets = [
          {:attribute => :followers_count},
          {:attribute => :friends_count},
          {:attribute => :favourites_count},
          {:attribute => :geo_enabled},
          {:attribute => :statuses_count},
          {:attribute => :lang},
          {:attribute => :time_zone},
          {:attribute => :created_at}
        ].collect{|fs| fs.merge(general_frequency_set_conditions)}
        BasicHistogram.generate_graphs(basic_histogram_frequency_sets, curation)
      end
    end
  end

  def self.resolve_time(granularity, time)
    year = nil
    month = nil
    date = nil
    hour = nil
    time = time.nil? ? "" : time
    case granularity
    when "hour"
      time = Time.parse(time)
      year = time.year
      month = time.month
      date = time.day
      hour = time.hour
    when "date"
      time = Time.parse(time)
      year = time.year
      month = time.month
      date = time.day
    when "month"
      time = Time.parse("#{time}-01")
      year = time.year
      month = time.month
    when "year"
      time = Time.parse("#{time}-01-01")
      year = time.year
    end
    return time, year, month, date, hour
  end
  
  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the Time-based Summary for the basic histograms in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files and online charts are ready for download and viewing. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
  
end