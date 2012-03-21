class GenderEstimation < AnalysisMetadata

  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    tk_environment = Setting.grab("trueknowledge")
    graphs = []
    gender_graph = Graph.first_or_create(:style => "histogram", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id, :title => "user_gender_mapping")
    gender_results = Graph.first_or_create(:style => "histogram", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id, :title => "user_gender_breakdown")
    graph_points = []
    gender_results_tracker = {}
    limit = 1000
    offset = 0
    users = User.all({:limit => limit, :offset => offset}.merge(conditional))
    while !users.empty?
      users.each do |user|
        # begin
          puts "#{users.index(user)}/#{users.length}"
          query = %(query+gender_common%0Agender+%5Bis+the+likely+gender+inferred+from+the+name%5D+%5Bpersonal+name%3A+%5B%22#{URI.encode(user.name)}%22%5D%5D%0Agender+%5Bcommonly+translates+as%5D+gender_common)
          api_url = "http://api.trueknowledge.com/query/?api_account_id=#{tk_environment[:username]}&api_password=#{tk_environment[:password]}&query=#{query}"
          result = (value_string = Nokogiri.parse(open(api_url).read.gsub(":", "_")).at("tk_id")).nil? ? "inconclusive" : value_string.children.first.text.gsub(/\W/, "")
          graph_point = {}
          graph_point[:label] = user.twitter_id
          graph_point[:value] = result
          graph_point[:graph_id] = gender_graph.id
          graph_point[:curation_id] = curation.id
          graph_point[:analysis_metadata_id] = @analysis_metadata.id
          gender_results_tracker[result].nil? ? gender_results_tracker[result]=1 : gender_results_tracker[result]+=1
          graph_points << graph_point
        # rescue Timeout::Error
        #   retry
        # rescue OpenURI::HTTPError
        #   next
        # end
      end
      offset+=offset
      users = User.all({:limit => limit, :offset => offset}.merge(conditional))
      if graph_points.length > DEFAULT_CHUNK_SIZE
        GraphPoint.save_all(graph_points)
        graph_points = []
      end
    end
    gender_results_tracker.each_pair do |k,v|
      graph_point = {}
      graph_point[:label] = k
      graph_point[:value] = v
      graph_point[:graph_id] = gender_results.id
      graph_point[:curation_id] = curation.id    
      graph_point[:analysis_metadata_id] = analysis_metadata&&analysis_metadata.id
      graph_points << graph_point
    end
    GraphPoint.save_all(graph_points)
  end
end