class WordFrequency < AnalysisMetadata
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

  def self.run(curation_id, save_path)
    curation = Curation.first({:id => curation_id})
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    self.generate_word_frequencies_from_entities({:frequency_type => "urls"}, conditional)
    self.generate_word_frequencies_from_entities({:frequency_type => "hashtags"}, conditional)
    self.generate_word_frequencies_from_entities({:frequency_type => "user_mentions"}, conditional)
    BasicHistogram.generate_graph_points([
      {:title => "urls", :frequency_type => "urls", :style => "word_frequencies"}, 
      {:title => "hashtags", :frequency_type => "hashtags", :style => "word_frequencies"}, 
      {:title => "user_mentions", :frequency_type => "user_mentions", :style => "word_frequencies"}
    ]) do |fs, graph, curation|
      self.generate_word_frequencies_from_entities(fs, graph, conditional)
    end
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end
  
  def self.generate_word_frequencies_from_entities(fs, graph, conditional, path=ENV['TMP_PATH'])
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    sub_directory = "/"+[fs[:year],fs[:month],fs[:date],fs[:hour]].compact.join("/")    
    full_path_with_file = sub_directory == "/" ? path+"/"+graph.title+".csv" : path+sub_directory+"/"+graph.title+".csv"
    Sh::mkdir(path+sub_directory) if sub_directory != "/"
    FasterCSV.open(full_path_with_file, "w") do |csv|
      records = Entity.aggregate(:kind, :all.count, {:limit => limit, :offset => offset}.merge(conditional).merge(self.conditional_from_frequency_type(frequency_type)))
      graph_points = records.collect{|record| {:label => record.first, :value => record.last, :graph_id => graph.id, :curation_id => graph.curation_id}}
      graph_points = graph.sanitize_points(graph_points)
      while !records.empty?
        csv << ["term", "count"]
        graph_points.each do |graph_point|
          csv << [graph_point[:label],graph_point[:value]]
        end
        GraphPoint.save_all(graph_points)
        offset+=limit
        records = Entity.aggregate(:kind, :all.count, {:limit => limit, :offset => offset}.merge(conditional).merge(self.conditional_from_frequency_type(frequency_type)))
      end
    end
  end
  
  def self.conditional_from_frequency_type(frequency_type)
    case frequency_type
    when "urls"
      {:kind => "urls", :name => "url"}
    when "hashtags"
      {:kind => "hashtags", :name => "text"}
    when "mentions"
      {:kind => "user_mentions", :name => "screen_name"}
    end
  end
  # def self.run(curation_id, save_path)
  #   curation = Curation.first({:id => curation_id})
  #   FilePathing.tmp_folder(curation, self.underscore)
  #   conditional = Analysis.curation_conditional(curation).merge({:fields => [:text]})
  #   frequency_listing = self.get_frequency_listing(query)
  #   general_frequency_set_conditions = {
  #     :model => model.to_class, 
  #     :attribute => :text,
  #     :conditional => conditional, 
  #     :style => "word_frequency"
  #   }
  #   generate_graph_points([
  #     {:title => "hashtags"}.merge(general_frequency_set_conditions),
  #     {:title => "mentions"}.merge(general_frequency_set_conditions),
  #     {:title => "significant_words"}.merge(general_frequency_set_conditions),
  #     {:title => "urls"}.merge(general_frequency_set_conditions)
  #   ]) do |fs, graph, curation|
  #     self.generate_word_frequency(fs, graph, curation, frequency_listing)
  #   end
  #   FilePathing.push_tmp_folder(save_path)
  # end
  # 
  # def self.get_frequency_listing(query)
  #   frequency_listing = {}
  #   num = 1
  #   objects = Database.spooled_result(query)
  #   while row = objects.fetch_row do
  #     num+=1
  #     row.first.super_split(" ").collect do |word|
  #       word = word.super_strip.downcase
  #       frequency_listing[word].nil? ? frequency_listing[word] = 1 : frequency_listing[word]+= 1
  #     end
  #   end
  #   Database.terminate_spooling
  #   objects.free
  #   return frequency_listing
  # end
  # 
  # def self.generate_word_frequency(fs, tmp_folder, frequency_listing, collection, graph)
  #   FasterCSV.open(tmp_folder+fs["title"]+".csv", "w") do |csv|
  #     csv << ["word", "occurrences"]
  #     graph_points = Pretty.pretty_up_labels(fs["style"], fs["title"], eval("hashes_to_graph_points(#{fs["title"]}(frequency_listing), collection, graph)"))
  #     graph_points.each do |row|
  #       csv << [row["label"],row["value"]]
  #     end
  #     @graph_points+=graph_points
  #   end
  #   check_for_save
  # end
  # 
  # def self.hashtags(frequency_listing)
  #   frequency_listing.reject{|k,v| !k.match(/^#/)}
  # end
  # 
  # def self.mentions(frequency_listing)
  #   new_listing = {}
  #   frequency_listing.reject{|k,v| !k.match(/^@/)}.each_pair do |k,v|
  #     new_k = k.gsub(/[.?*!:]/, "")
  #     if new_listing[new_k]
  #       new_listing[new_k] += v
  #     else
  #       new_listing[new_k] = v
  #     end
  #   end
  #   return new_listing
  # end
  # 
  # def self.significant_words(frequency_listing)
  #   stop_words = File.open(ROOT_FOLDER+"cluster-code/analyzer/resources/stop_words.txt").read.split
  #   frequency_listing.reject{|k,v| stop_words.include?(k) || k.include?("@") || k.include?("#")|| k.include?("http")}
  # end
  # 
  # def self.urls(frequency_listing)
  #   frequency_listing.reject{|k,v| !k.include?("http")}
  # end
  # 
  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, your word frequency charts for the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files and online charts are ready for download and viewing. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response    
  end
end
