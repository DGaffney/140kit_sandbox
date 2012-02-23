class JaccardToCsv < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000
  MAX_ROW_COUNT_PER_BATCH = 1000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  #!!! Change tolerance to percentile. Calculate all jaccard coefficients that are more than 0.0. Store all of these, then delete ones that are below the given percentile variable. Badass.
  def self.run(curation_id, percentile)
    curation = Curation.first(:id => curation_id)
    return nil if !self.requires(self.analysis_metadata(curation), [{:function => "jaccard_soft_retweet_calculator", :with_options => [curation_id, percentile]}], curation)
    FilePathing.tmp_folder(curation, self.underscore)
    analysis_metadata = self.analysis_metadata(curation)
    conditional = Analysis.curation_conditional(curation)
    research_database = connect_to_db("research")
    if research_database.nil?
      self.boot_out
      return nil
    end
    self.generate_jaccard_graph(curation, analysis_metadata.id)
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.generate_jaccard_graph(curation, analysis_metadata_id, path=ENV['TMP_PATH'])
    parent_analysis_metadata_run_vars = AnalysisMetadata.first(:id => analysis_metadata_id).run_vars
    parent_analysis_metadata = AnalysisMetadata.all("analytical_offering.function" => "jaccard_soft_retweet_calculator").select{|analysis_metadata| analysis_metadata.run_vars == parent_analysis_metadata_run_vars}.first
    BasicHistogram.generate_graphs([{:model => JaccardCoefficient,  :attribute => :social_flow_tweet_twitter_id, :title => "total_per_social_flow_tweet", :override_conditional => true, :conditional => {:analysis_metadata_id => parent_analysis_metadata.id, :curation_id => curation.id}}], curation, self)
    BasicHistogram.generate_graphs([
      {:model => JaccardCoefficient, :title => "all_jaccard_coefficients", :generate_graph_points => false, :override_conditional => true, :conditional => {:analysis_metadata_id => parent_analysis_metadata.id, :curation_id => curation.id}},
      {:model => JaccardCoefficient, :title => "all_jaccard_coefficients_within_percentile", :conditional => {:within_percentile => true, :analysis_metadata_id => parent_analysis_metadata.id, :curation_id => curation.id}, :generate_graph_points => false, :override_conditional => true}
    ], curation, self) do |fs, graph, conditional|
      BasicHistogram.frequency_graphs(fs, graph, conditional, path) do |fs, graph, conditional, csv, limit, offset|
        keys = [:referencing_tweet_twitter_id, :within_percentile, :coefficient, :social_flow_tweet_twitter_id]
        csv << keys.collect{|key| key.to_s}
        records = JaccardCoefficient.all(conditional.merge(:limit => limit, :offset => offset))
        while !records.empty?
          records.each do |record|
            record = record.attributes
            csv << keys.collect{|key| record[key]}
          end
          records = JaccardCoefficient.all(conditional.merge(:limit => limit, :offset => offset))
          offset+=limit
        end
      end
    end
  end
  
  def self.finalize_analysis(curation)
    response = {}
    return response
  end
end
