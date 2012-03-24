class GeoMap < AnalysisMetadata
  
  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    location_overview = Graph.first_or_create(:title => "location_overview", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    graph_points = []
    tweet_count = Tweet.count(conditional)
    graph_points << {:label => "total_tweets", :value => tweet_count, :curation_id => curation.id, :graph_id => location_overview.id, :analysis_metadata_id => @analysis_metadata.id}
    geo_count = Geo.count(conditional)
    graph_points << {:label => "total_geos", :value => geo_count, :curation_id => curation.id, :graph_id => location_overview.id, :analysis_metadata_id => @analysis_metadata.id}
    coordinate_count = Coordinate.count(conditional)
    graph_points << {:label => "total_coordinates", :value => coordinate_count, :curation_id => curation.id, :graph_id => location_overview.id, :analysis_metadata_id => @analysis_metadata.id}
    graph_points << {:label => "proportion_geos", :value => geo_count/tweet_count.to_f, :curation_id => curation.id, :graph_id => location_overview.id, :analysis_metadata_id => @analysis_metadata.id}
    graph_points << {:label => "proportion_coordinates", :value => coordinate_count/tweet_count.to_f, :curation_id => curation.id, :graph_id => location_overview.id, :analysis_metadata_id => @analysis_metadata.id}
    country_map = Graph.first_or_create(:title => "country_map", :style => "map", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    city_map = Graph.first_or_create(:title => "city_map", :style => "map", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    offset = 0
    limit = 1000
    geos = DataMapper.repository.adapter.select("select count(*) as country_count, country_code from geos #{Analysis.conditions_to_mysql_query(conditional)} group by country limit #{limit} offset #{offset}")
    while !geos.empty?
      geos.each do |geo|
        graph_points << {:label => geo.country_code, :value => geo.country_count, :curation_id => curation.id, :graph_id => country_map.id, :analysis_metadata_id => @analysis_metadata.id}
      end
      offset += limit
      geos = DataMapper.repository.adapter.select("select count(*) as country_count, country_code from geos #{Analysis.conditions_to_mysql_query(conditional)} group by country limit #{limit} offset #{offset}")
    end
    GraphPoint.save_all(graph_points)
    graph_points = []
    offset = 0
    geos = DataMapper.repository.adapter.select("select count(geos.*) as full_name_count, geos.full_name as full_name, geos.country as country, coordinates.lat as lat, coordinates.lon as lon from geos inner join coordinates on geos.geo_id = coordinates.geo_id #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id", "geos.dataset_id")} group by full_name limit #{limit} offset #{offset}")
    while !geos.empty?
      geos.each do |geo|
        graph_points << {:label => "#{geo.full_name}, #{geo.country} | #{geo.lat},#{geo.lon}", :value => geo.full_name_count, :curation_id => curation.id, :graph_id => city_map.id, :analysis_metadata_id => @analysis_metadata.id}
      end
      GraphPoint.save_all(graph_points)
      graph_points = []
      offset += limit
      geos = DataMapper.repository.adapter.select("select count(geos.*) as full_name_count, geos.full_name as full_name, geos.country as country, coordinates.lat as lat, coordinates.lon as lon from geos inner join coordinates on geos.geo_id = coordinates.geo_id #{Analysis.conditions_to_mysql_query(conditional).gsub("dataset_id", "geos.dataset_id")} group by full_name limit #{limit} offset #{offset}")
    end
    GraphPoint.save_all(graph_points)
    return true
  end
end