class EntityExtractor < AnalysisMetadata

  def self.run(analysis_metadata_id)
    debugger
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    entities = Entity.all({:fields => [:name], :unique => true}.merge(conditional)).collect{|e| e.name}
    graph_sets = {"hashtag" => "text", "mention" => "screen_name", "url" => "expanded_url"}
    graph_sets.each_pair do |graph_title, name|
      graph = Graph.first_or_create(:title => graph_title, :style => "histogram", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
      offset = 0
      limit = 1000
      entities = DataMapper.repository.adapter.select("select count(*) as count,value from entities #{Analysis.conditions_to_mysql_query(conditional)} and name = '#{name}' group by value order by count(*) desc limit #{limit} offset #{offset}")
      graph_points = []
      while !entities.empty?
        entities.each do |entity|
          graph_points << {:graph_id => graph.id, :label => entity.value, :value => entity.count, :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id}
        end
        GraphPoint.save_all(graph_points)
        graph_points = []
        offset+=limit
        entities = DataMapper.repository.adapter.select("select count(*) as count,value from entities #{Analysis.conditions_to_mysql_query(conditional)} and name = '#{name}' group by value order by count(*) desc limit #{limit} offset #{offset}")
      end
    end
  end
  
end