class InteractionList < AnalysisMetadata

  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    graph = Graph.first_or_create(:title => "interaction_list", :style => "network", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    offset = 0
    limit = 1000
    interactions = DataMapper.repository.adapter.select("select tweets.screen_name as start_node,tweets.twitter_id as edge_id, tweets.retweeted as retweeted, tweets.created_at as time, entities.value as end_node from tweets inner join entities on tweets.twitter_id = entities.twitter_id #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id", "entities.dataset_id")} and entities.name = 'screen_name' limit #{limit} offset #{offset}")
    edges = []
    while !interactions.empty?
      interactions.each do |interaction|
        style = interaction.retweeted ? "retweet" : "mention"
        edges << {:start_node => interaction.start_node, :end_node => interaction.end_node, :edge_id => interaction.edge_id, :time => interaction.time, :style => style, :analysis_metadata_id => @analysis_metadata.id, :graph_id => graph.id, :curation_id => curation.id}
      end
      offset += limit
      interactions = DataMapper.repository.adapter.select("select tweets.screen_name as start_node,tweets.twitter_id as edge_id, tweets.retweeted as retweeted, tweets.created_at as time, entities.value as end_node from tweets inner join entities on tweets.twitter_id = entities.twitter_id #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id", "entities.dataset_id")} and entities.name = 'screen_name' limit #{limit} offset #{offset}")
      Edge.save_all(edges)
      edges = []
    end
  end
end
