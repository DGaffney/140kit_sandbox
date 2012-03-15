# obl_retweet_graph = AnalyticalOffering.create(:title => "OBL Retweet Graph Pruner", :function => "obl_retweet_graph", :language => "ruby", :created_by => "140kit Team", :created_by_link => "http://140kit.com", :access_level => "user", :description => "OBL RETWEET GRAPH")
# obl_retweet_graph_var_0 = AnalyticalOfferingVariableDescriptor.create(:name => "curation_id", :position => 0, :kind => "integer", :analytical_offering_id=> obl_retweet_graph.id, :description => "Curation ID for set to be analyzed")

class OblRetweetGraph < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000
  MAX_ROW_COUNT_PER_BATCH = 1000
    
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id)
    curation = Curation.first(:id => curation_id)
    FilePathing.tmp_folder(curation, self.underscore)
    return nil if !self.requires(self.analysis_metadata(curation), [{:function => "obl_retweet_graph_pruner", :with_options => [curation_id]}], curation)
    prior_analysis_metadata = AnalysisMetadata.all("analytical_offering.function" => "obl_retweet_graph_pruner").select{|analysis_metadata| analysis_metadata.run_vars == self.analysis_metadata(curation).run_vars}
    retweet_graph_versions = []
    if prior_analysis_metadata
      graphs = Graph.all(:curation_id => curation_id, :analysis_metadata_id => prior_analysis_metadata.id)
      @edges = []
      graphs.each do |graph|
        retweet_graph_version = Graph.create(:title => graph.title, :style => "network", :curation_id => graph.curation_id, :analysis_metadata_id => self.analysis_metadata(curation).id)
        retweet_graph_versions << retweet_graph_version
        limit = DEFAULT_CHUNK_SIZE
        offset = 0
        twitter_ids = GraphPoint.all(:graph_id => graph.id, :limit => limit, :offset => offset).collect{|graph_point| graph_point.value}
        while !twitter_ids.nil?
          tweets = Tweet.all(:twitter_id => twitter_ids, :in_reply_to_user_id.not => nil)
          tweets.each do |tweet|
            @edges << {:start_node => tweet.in_reply_to_screen_name, :end_node => tweet.screen_name, :edge_id => tweet.twitter_id, :time => tweet.created_at, :graph_id => retweet_graph_version.id, :curation_id => curation.id, :analysis_metadata_id => retweet_graph_version.analysis_metadata_id, :style => RetweetGraph.derive_style_from_tweet(tweet)}
          end
          if @edges.length >= MAX_ROW_COUNT_PER_BATCH
            Edge.save_all(@edges)
            @edges = []
          end
          offset += limit
          twitter_ids = GraphPoint.all(:graph_id => graph.id, :limit => limit, :offset => offset).collect{|graph_point| graph_point.value}
        end
      end
    end
    Edge.save_all(@edges)
    retweet_graph_versions.each do |graph|
      options = {:dynamic => true, :formats => ["gexf", "graphml"], :node_attributes => [:statuses_count, :followers_count, :friends_count], :edge_attributes => [:style]}
      frequency_set = {:analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id, :style => "network_graph", :title => graph.title}.merge(options)
      RetweetGraph.generate_graph_files(frequency_set, graph)
    end
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "DONE"
    response[:message_content] = "ITS DONE"
    return response
  end
end
