class GenderEstimation < AnalysisMetadata
  DEFAULT_CHUNK_SIZE = 1000

  def self.run(curation_id)
    curation = Curation.first(:id => curation_id)
    conditional = Analysis.curation_conditional(curation)
    FilePathing.tmp_folder(curation, self.underscore)
    tk_environment = load_config_file("api_keys")["trueknowledge"]
    path=ENV['TMP_PATH']
    Sh::mkdir(path)
    analysis_metadata = self.analysis_metadata(curation)
    graphs = []
    BasicHistogram.generate_graphs([
      {:analysis_metadata_id => analysis_metadata&&analysis_metadata.id, :style => "histogram", :title => "user_gender_mapping"},
      {:analysis_metadata_id => analysis_metadata&&analysis_metadata.id, :style => "histogram", :title => "user_gender_breakdown"}], curation) do |fs, graph, conditional|
        graphs << graph
    end
    gender_graph, gender_results = graphs
    graph_points = []
    gender_results_tracker = {}
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    users = User.all({:limit => limit, :offset => offset}.merge(conditional))
    full_path_with_file = path+"/"+gender_graph.title+".csv"
    FasterCSV.open(full_path_with_file, "w") do |csv|
      csv << ["Account", "Twitter ID", "Name", "Gender"]
      while !users.empty?
        users.each do |user|
          begin
            query = %(query+gender_common%0Agender+%5Bis+the+likely+gender+inferred+from+the+name%5D+%5Bpersonal+name%3A+%5B%22#{URI.encode(user.name)}%22%5D%5D%0Agender+%5Bcommonly+translates+as%5D+gender_common)
            api_url = "http://api.trueknowledge.com/query/?api_account_id=#{tk_environment["username"]}&api_password=#{tk_environment["password"]}&query=#{query}"
            result = (value_string = Nokogiri.parse(open(api_url).read.gsub(":", "_")).at("tk_id")).nil? ? "inconclusive" : value_string.children.first.gsub(/\\|\[|\]|\"/, "")
            graph_point = {}
            graph_point[:label] = user.twitter_id
            graph_point[:value] = result
            graph_point[:graph_id] = gender_graph.id
            graph_point[:curation_id] = curation.id
            graph_point[:analysis_metadata_id] = analysis_metadata&&analysis_metadata.id
            csv << [user.screen_name, user.twitter_id, user.name, result]
            gender_results_tracker[result].nil? ? gender_results_tracker[result]=1 : gender_results_tracker[result]+=1
            graph_points << graph_point
          rescue Timeout::Error
            next
          rescue OpenURI::HTTPError
            next
          end
        end
        offset+=offset
        users = User.all({:limit => limit, :offset => offset}.merge(conditional))
        if graph_points.length > DEFAULT_CHUNK_SIZE
          GraphPoint.save_all(graph_points)
          graph_points = []
        end
      end
    end
    full_path_with_file = sub_directory == "/" ? path+"/"+gender_graph.title+".csv" : path+sub_directory+"/"+gender_graph.title+".csv"    
    FasterCSV.open(full_path_with_file, "w") do |csv|
      csv << ["Gender", "Total"]
      gender_results_tracker.each_pair do |k,v|
        graph_point = {}
        graph_point[:label] = k
        graph_point[:value] = v
        graph_point[:graph_id] = gender_results.id
        graph_point[:curation_id] = curation.id    
        graph_point[:analysis_metadata_id] = analysis_metadata&&analysis_metadata.id
        csv << [k,v]
        graph_points << graph_point
      end
    end
    GraphPoint.save_all(graph_points)
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end
end

module Hpricot

  # Monkeypatch to fix an Hpricot bug that causes HTML entities to be decoded
  # incorrectly.
  def self.uxs(str)
    str.to_s.
      gsub(/&(\w+);/) { [Hpricot::NamedCharacters[$1] || ??].pack("U*") }.
      gsub(/\&\#(\d+);/) { [$1.to_i].pack("U*") }
  end

end