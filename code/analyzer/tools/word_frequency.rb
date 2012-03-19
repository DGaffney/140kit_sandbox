class WordFrequency < AnalysisMetadata
  DEFAULT_CHUNK_SIZE = 1000

  def self.run(curation_id)
    curation = Curation.first({:id => curation_id})
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    # self.generate_word_frequencies_from_entities({:frequency_type => "urls"}, conditional)
    # self.generate_word_frequencies_from_entities({:frequency_type => "hashtags"}, conditional)
    # self.generate_word_frequencies_from_entities({:frequency_type => "user_mentions"}, conditional)
    BasicHistogram.generate_graphs([
      {:title => "urls", :frequency_type => "urls", :style => "word_frequencies", :analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id}, 
      {:title => "hashtags", :frequency_type => "hashtags", :style => "word_frequencies", :analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id}, 
      {:title => "user_mention_screen_names", :frequency_type => "user_mention_screen_names", :style => "word_frequencies", :analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id},
      {:title => "user_mention_ids", :frequency_type => "user_mention_ids", :style => "word_frequencies", :analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id}
    ], curation, self) do |fs, graph, conditional|
      self.generate_word_frequencies_from_entities(fs, graph, conditional)
    end
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize_work(curation)
  end
  
  def self.generate_word_frequencies_from_entities(fs, graph, conditional, path=ENV['TMP_PATH'])
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    sub_directory = "/"+[fs[:year],fs[:month],fs[:date],fs[:hour]].compact.join("/")    
    full_path_with_file = sub_directory == "/" ? path+"/"+graph.title+".csv" : path+sub_directory+"/"+graph.title+".csv"
    Sh::mkdir(path+sub_directory, {"type"=>"local"}) if sub_directory != "/"
    csv = CSV.open(full_path_with_file, "w")
      records = Entity.aggregate(:value, :all.count, {:limit => limit, :offset => offset}.merge(conditional).merge(self.conditional_from_frequency_type(fs[:frequency_type])))
      while !records.empty?
        graph_points = records.collect{|record| {:label => record.first, :value => record.last, :graph_id => graph.id, :curation_id => graph.curation_id, :analysis_metadata_id => graph.analysis_metadata_id}}
        graph_points = graph.sanitize_points(graph_points)
        GraphPoint.save_all(graph_points)
        csv << ["term", "count"]
        graph_points.each do |graph_point|
          csv << [graph_point[:label],graph_point[:value]]
        end
        offset+=limit
        records = Entity.aggregate(:value, :all.count, {:limit => limit, :offset => offset}.merge(conditional).merge(self.conditional_from_frequency_type(fs[:frequency_type])))
      end
    graph.written = true
    graph.save!
  end
  
  def self.conditional_from_frequency_type(frequency_type)
    case frequency_type
    when "urls"
      {:name => "url"}
    when "hashtags"
      {:name => "text"}
    when "user_mention_screen_names"
      {:name => "screen_name"}
    when "user_mention_ids"
      {:name => "id"}
    end
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, your word frequency charts for the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files and online charts are ready for download and viewing. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response    
  end
end
