class TimeBasedSummary < AnalysisMetadata
  def self.set_variables(analysis_metadata, curation)
    remaining_variables = []
    analysis_metadata.analytical_offering.variables.each do |variable|
      analytical_offering_variable = AnalyticalOfferingVariable.new
      analytical_offering_variable.analytical_offering_variable_descriptor_id = variable.id
      analytical_offering_variable.analysis_metadata_id = analysis_metadata.id
      case variable.name
      when "curation_id"
        analytical_offering_variable.value = curation.id
        analytical_offering_variable.save
      when "save_path"
        analytical_offering_variable.value = "analytical_results/#{analysis_metadata.function}"
        analytical_offering_variable.save
      else
        remaining_variables << variable
      end
    end
    return remaining_variables
  end
  
  def self.verify_variable(metadata, variable_descriptor, answer, curation)
    case variable_descriptor.name
    when "granularity"
      valid_responses = ["year", "month", "date", "hour"]
      response = {}
      response[:reason] = "You may only choose one of these options, and only these options (can't be left blank). You entered: #{answer}. You can choose from ['year','month','date','hour']."
      response[:variable] = answer
      return response if !valid_responses.include?(answer)
    end
    return {:variable => answer}
  end
  
  def self.run(curation_id, save_path, granularity)
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
      when "sqlite"
        user_timeline = DataMapper.repository.adapter.select("select date_format(created_at, '#{time_query}') as created_at from users where"+Analysis.conditions_to_mysql_query(conditional)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
        tweet_timeline = DataMapper.repository.adapter.select("select date_format(created_at, '#{time_query}') as created_at from tweets where"+Analysis.conditions_to_mysql_query(conditional)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
      when "memory"
        user_timeline = User.all(conditional).select{|u| u.created_at.year}.uniq
        tweet_timeline = Tweet.all(conditional).select{|u| u.created_at.year}.uniq
      end
      self.time_based_analytics("tweets", time_query, tweet_timeline, curation, time_granularity, save_path)
      self.time_based_analytics("users", time_query, user_timeline, curation, time_granularity, save_path)
    end
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.resolve_time_query(time_granularity)
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
        :time_slice => time_slice, 
        :granularity => granularity, 
        :year => year, 
        :month => month, 
        :date => date, 
        :hour => hour
      }
      case model
      when "tweets"
        # frequency_listing = get_frequency_listing("select text from tweets "+Analysis.conditional(curation)+" and "+Analysis.time_conditional("created_at", object_group["created_at"], granularity))
        basic_histogram_frequency_sets = [
          {:attribute => :language},
          {:attribute => :created_at},
          {:attribute => :source},
          {:attribute => :location}
        ].collect{|fs| fs.merge(general_frequency_set_conditions)}
        BasicHistogram.generate_graph_points(basic_histogram_frequency_sets, curation)
        # generate_graph_points([
        #   {:model => Tweet, "title" => "hashtags",          "style" => "word_frequency", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        #   {:model => Tweet, "title" => "mentions",          "style" => "word_frequency", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        #   {:model => Tweet, "title" => "significant_words", "style" => "word_frequency", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        #   {:model => Tweet, "title" => "urls",              "style" => "word_frequency", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity}]) do |fs, graph, tmp_folder|
        #     generate_word_frequency(fs, tmp_folder, frequency_listing, collection, graph)
        # end
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
        BasicHistogram.generate_graph_points(basic_histogram_frequency_sets, curation)
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
end