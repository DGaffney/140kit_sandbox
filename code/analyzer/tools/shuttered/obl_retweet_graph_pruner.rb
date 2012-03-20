# obl_retweet_graph_pruner = AnalyticalOffering.create(:title => "OBL Retweet Graph Pruner", :function => "obl_retweet_graph_pruner", :language => "ruby", :created_by => "140kit Team", :created_by_link => "http://140kit.com", :access_level => "user", :description => "OBL RETWEET GRAPH PRUNER")
# obl_retweet_graph_pruner_var_0 = AnalyticalOfferingVariableDescriptor.create(:name => "curation_id", :position => 0, :kind => "integer", :analytical_offering_id=> obl_retweet_graph_pruner.id, :description => "Curation ID for set to be analyzed")

class OblRetweetGraphPruner < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000
  MAX_ROW_COUNT_PER_BATCH = 1000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id)
    curation = Curation.first(:id => curation_id)
    obama_tweets = Graph.create(:title => "obama_tweets", :style => "histogram", :curation_id => curation_id, :analysis_metadata_id => self.analysis_metadata(curation).id)
    osama_tweets = Graph.create(:title => "osama_tweets", :style => "histogram", :curation_id => curation_id, :analysis_metadata_id => self.analysis_metadata(curation).id)
    abbottabad_tweets = Graph.create(:title => "osama_tweets", :style => "histogram", :curation_id => curation_id, :analysis_metadata_id => self.analysis_metadata(curation).id)
    really_virtual_tweets = Graph.create(:title => "really_virtual_tweets", :style => "histogram", :curation_id => curation_id, :analysis_metadata_id => self.analysis_metadata(curation).id)
    #include likely subject/predicate/objects for germane tweets, then employ them on lookups for the tweets
    terms = {
      obama_tweets => [
        ["WH", "statement", "white house", "announce", "announcement", "security", "national", "natl", "natl sec", "national security"], 
        ["obama", "pres.", "president", "barack"], 
        ["10:30", "EST", "ET", "PM", "2230", "22:30", "10pm", "1030pm"]
        ],
      osama_tweets => [
        ["OBL", "osama", "bin laden", "osama bin laden", "captured", "killed", "shot", "wounded", "found"]
        ],
      abbottabad_tweets => [
        ["helicopter", "ufo","abbottabad", "pakistan", "kakool", "pma kakool", "kakoool", "tabaaah"],
        ["explosion", "bomb", "1am", "reallyvirtual"]
        ]
    }
    @graph_points = []
    terms.each_pair do |graph, terms|
      offset = 0
      limit = DEFAULT_CHUNK_SIZE
      terms_conditional = "("+terms.collect{|term_set| "'%"+term_set.join("%' or text like '%")+"%'"}.join(") and (text like ")+")"
      query = lambda{|terms_conditional, curation, limit, offset| "select * from tweets where #{terms_conditional} and #{Analysis.conditions_to_mysql_query(Analysis.curation_conditional(curation))} limit #{limit} offset #{offset}"}
      records = DataMapper.repository.adapter.select(query.call(terms_conditional, curation, limit, offset))
      while !records.nil?
        records.each do |record|
          @graph_points << {:label => graph.title, :value => record.twitter_id, :graph_id => graph.id, :curation_id => graph.curation_id}
        end
        if @graph_points.length>=MAX_ROW_COUNT_PER_BATCH
          GraphPoint.save_all(@graph_points)
          @graph_points = []
        end
        offset += limit
        records = DataMapper.repository.adapter.select(query.call(terms_conditional, curation, limit, offset))
      end
    end
    GraphPoint.save_all(@graph_points)      
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