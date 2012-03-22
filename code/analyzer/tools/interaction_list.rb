class InteractionList < AnalysisMetadata

  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    self.calculate_raw_edges(curation, conditional)
    self.calculate_degrees(curation, conditional)
    self.calculate_overview(curation)
  end
  
  def self.calculate_raw_edges(curation, conditional)
    retweet_network = Graph.first_or_create(:title => "retweet_network", :style => "network", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    mention_network = Graph.first_or_create(:title => "mention_network", :style => "network", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    edges = []
    offset = 0
    limit = 1000
    interactions = DataMapper.repository.adapter.select("select tweets.screen_name as start_node,tweets.twitter_id as edge_id, tweets.in_reply_to_status_id as retweeted, tweets.created_at as time, entities.value as end_node from tweets inner join entities on tweets.twitter_id = entities.twitter_id #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id", "entities.dataset_id")} and entities.name = 'screen_name' limit #{limit} offset #{offset}")
    while !interactions.empty?
      interactions.each do |interaction|
        style = interaction.retweeted.nil? ? "mention" : "retweet"
        graph = interaction.retweeted.nil? ? mention_network : retweet_network
        edge = {:start_node => interaction.start_node, :end_node => interaction.end_node, :edge_id => interaction.edge_id, :time => interaction.time, :style => style, :analysis_metadata_id => @analysis_metadata.id, :graph_id => graph.id, :curation_id => curation.id}
        edges << edge
      end
      offset += limit
      interactions = DataMapper.repository.adapter.select("select tweets.screen_name as start_node,tweets.twitter_id as edge_id, tweets.retweeted as retweeted, tweets.created_at as time, entities.value as end_node from tweets inner join entities on tweets.twitter_id = entities.twitter_id #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id", "entities.dataset_id")} and entities.name = 'screen_name' limit #{limit} offset #{offset}")
      Edge.save_all(edges)
      edges = []
    end
  end
  
  def self.calculate_degrees(curation, conditional)
    degrees = []
    graph_set = {:retweet_out_degrees => ["start_node", "retweet"], :retweet_in_degrees => ["end_node", "retweet"], :mention_out_degrees => ["start_node", "mention"], :mention_in_degrees => ["start_node", "retweet"]}
    graph_set.each_pair do |name, settings|
      graph = Graph.first_or_create(:title => name.to_s, :style => "histogram", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
      offset = 0
      limit = 1000
      edges = DataMapper.repository.adapter.select("select #{settings.first} as account,count(*) as count from edges where curation_id = #{curation.id} and style = '#{settings.last}' group by #{settings.first} order by count(*) desc limit #{limit} offset #{offset};")
      while !edges.empty?
        edges.each do |edge|
          degrees << {:graph_id => graph.id, :label => edge.account, :value => edge.count, :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id}
        end
        offset += limit
        edges = DataMapper.repository.adapter.select("select #{settings.first} as account,count(*) as count from edges where curation_id = #{curation.id} and style = '#{settings.last}' group by #{settings.first} order by count(*) desc limit #{limit} offset #{offset};")
        GraphPoint.save_all(degrees)
        degrees = []
      end
    end
  end
  
  def self.calculate_overview(curation)
    overview_graph = Graph.first_or_create(:title => "overview", :style => "network", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    overview = {:total_retweets => 0, :total_mentions => 0, :average_comentions => 0, :average_coretweets => 0, :most_mentioning => "", :most_mentioned => "", :most_retweeting => "", :most_retweeted => "", :total_distinct_retweets => 0, :total_distinct_mentions => 0}
    overview[:total_distinct_retweets] = DataMapper.repository.adapter.select("select count(distinct(edge_id)) from edges where curation_id = #{curation.id} and style = 'retweet'")
    overview[:total_distinct_mentions] = DataMapper.repository.adapter.select("select count(distinct(edge_id)) from edges where curation_id = #{curation.id} and style = 'mention'")
    retweet_network = Graph.first_or_create(:title => "retweet_network", :style => "network", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    mention_network = Graph.first_or_create(:title => "mention_network", :style => "network", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    overview[:total_retweets] = Edge.count(:style => 'retweet', :curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => retweet_network.id)
    overview[:total_mentions] = Edge.count(:style => 'mention', :curation_id => curation.id, :analysis_metadata_id => @analysis_metadata.id, :graph_id => mention_network.id)
    ["retweet", "mention"].each do |style|
      offset = 0
      limit = 1000
      counts = DataMapper.repository.adapter.select("select count(*) as count from edges where curation_id = #{curation.id} and style = '#{style}' group by edge_id order by count(*) desc limit #{limit} offset #{offset};")
      while !counts.empty?
        counts.each do |count|
          if style == "retweet"
            overview[:average_coretweets] += count.count
          else
            overview[:average_comentions] += count.count
          end
        end
        offset += limit
        counts = DataMapper.repository.adapter.select("select count(*) as count from edges where curation_id = #{curation.id} and style = '#{style}' group by edge_id order by count(*) desc limit #{limit} offset #{offset};")
      end
    end
    overview[:average_coretweets] = overview[:average_coretweets]/overview[:total_distinct_retweets].to_f
    overview[:average_comentions] = overview[:average_comentions]/overview[:total_distinct_mentions].to_f
    graph = Graph.first(:title => "retweet_out_degrees", :analysis_metadata_id => @analysis_metadata.id, :curation => curation.id)
    overview[:most_retweeting] = DataMapper.repository.adapter.select("select * from graph_points where graph_id = #{graph.id} order by cast(value as signed) desc limit 1;").first.label
    graph = Graph.first(:title => "retweet_in_degrees", :analysis_metadata_id => @analysis_metadata.id, :curation => curation.id)
    overview[:most_retweeted] = DataMapper.repository.adapter.select("select * from graph_points where graph_id = #{graph.id} order by cast(value as signed) desc limit 1;").first.label
    graph = Graph.first(:title => "mention_out_degrees", :analysis_metadata_id => @analysis_metadata.id, :curation => curation.id)
    overview[:most_mentioning] = DataMapper.repository.adapter.select("select * from graph_points where graph_id = #{graph.id} order by cast(value as signed) desc limit 1;").first.label
    graph = Graph.first(:title => "mention_in_degrees", :analysis_metadata_id => @analysis_metadata.id, :curation => curation.id)
    overview[:most_mentioned] = DataMapper.repository.adapter.select("select * from graph_points where graph_id = #{graph.id} order by cast(value as signed) desc limit 1;").first.label
    graph_points = []
    overview.each_pair do |label, value|
      graph_points << {:label => label, :value => value, :graph_id  => overview_graph.id, :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id}
    end
    GraphPoint.save_all(graph_points)
  end
end
