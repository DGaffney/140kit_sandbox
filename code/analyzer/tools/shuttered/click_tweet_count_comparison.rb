class ClickTweetCountComparison < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id)
    curation = Curation.first(:id => curation_id)
    return nil if !self.requires(self.analysis_metadata(curation), [{:function => "click_counter", :with_options => [curation_id]},{:function => "basic_histogram", :with_options => [curation_id, "analytical_results/basic_histogram"]}], curation)
    FilePathing.tmp_folder(curation, self.underscore)
    click_graph = Graph.first(:title => "click_count", :style => "histogram", :curation_id => curation_id, :year => nil, :month => nil, :date => nil, :hour => nil, :time_slice => nil)
    count_graph = Graph.first(:title => "urls", :style => "word_frequencies", :curation_id => curation_id, :year => nil, :month => nil, :date => nil, :hour => nil, :time_slice => nil)
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    sub_directory = "/"+[click_graph.year,click_graph.month,click_graph.date,click_graph.hour].compact.join("/")
    path = ENV['TMP_PATH']
    full_path_with_file = sub_directory == "/" ? path+"/"+"click_tweet_count_comparison.csv" : path+sub_directory+"/"+"click_tweet_count_comparison.csv"
    FasterCSV.open(full_path_with_file, "w") do |csv|
      click_records = GraphPoint.all(:graph_id => click_graph.id, :limit => limit, :offset => offset)
      count_records = GraphPoint.all(:graph_id => count_graph.id, :label => click_records.collect{|click_record| click_record.label})
      csv << ["url", "clicks_count", "tweet_appearances"]
      while !click_records.empty?
        count_records.each do |count_record|
          click_record = click_records.select{|click_record| click_record.label == count_record.label}.first
          csv << [count_record.label, click_record.value, count_record.value] if click_record
        end
        offset+=limit
        click_records = GraphPoint.all(:graph_id => click_graph.id, :limit => limit, :offset => offset)
        count_records = GraphPoint.all(:graph_id => count_graph.id, :label => click_records.collect{|click_record| click_record.label})
      end
    end
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the raw Click data for the  click counter in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end
