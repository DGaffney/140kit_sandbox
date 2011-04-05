class RetweetGraph < AnalysisMetadata
  DEFAULT_CHUNK_SIZE = 1000
  def self.set_variables(analysis_metadata, curation)
    remaining_variables = []
    analysis_metadata.analytical_offering.variables.each do |variable|
      analytical_offering_variable = AnalyticalOfferingVariable.new
      analytical_offering_variable.analytical_offering_variable_descriptor_id = variable.id
      analytical_offering_variable.analysis_metadata_id = analysis_metadata.id
      case variable.name
      when "curation_id"
        analytical_offering_variable.value = curation.id
        analytical_offering_variable.save
      when "save_path"
        analytical_offering_variable.value = "analytical_results/#{analysis_metadata.function}"
        analytical_offering_variable.save
      else
        remaining_variables << variable
      end
    end
    return remaining_variables
  end

  def self.run(curation_id, save_path)
    curation = Curation.first({:id => curation_id})
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    BasicHistogram.generate_graphs([{:analysis_metadata_id => self.analysis_metadata&&self.analysis_metadata.id, :style => "network_graph", :title => "conversational_tweets"}], curation) do |fs, graph, curation|
      self.generate_edges(fs, graph, conditional)
      self.generate_graph_files(fs, graph, conditional)
    end
    graph = Graph.first_or_create({:curation_id => curation_id, :analysis_metadata_id => self.analysis_metadata&&self.analysis_metadata.id}.merge(graph_attrs))
  end
  
  def self.generate_edges(fs, graph, conditional)
    debugger
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    records = Tweet.all(conditional.merge({:fields => [:screen_name, :twitter_id, :in_reply_to_status_id, :created_at, :in_reply_to_screen_name], :in_reply_to_user_id.not => nil, :limit => limit, :offset => offset}))
    edges = []
    while !records.empty?
      records.each do |record|
        edge = {:start_node => record.in_reply_to_screen_name, :end_node => record.screen_name, :edge_id => record.twitter_id, :time => record.created_at, :curation_id => graph.curation_id, :graph_id => graph.id, :style => self.derive_style_from_tweet(record)}
        edges << edge
      end
      Edge.save_all(edges)
      edges = []
      offset+=limit
      records = Tweet.all(conditional.merge({:fields => [:screen_name, :twitter_id, :in_reply_to_status_id, :created_at, :in_reply_to_screen_name], :in_reply_to_user_id.not => nil, :limit => limit, :offset => offset}))      
    end
  end
  
  def self.generate_graph_files(fs, graph, conditional)
    debugger
    start_node_limit = DEFAULT_CHUNK_SIZE||1000
    start_node_offset = 0
    start_nodes = graph.edges.aggregate(:start_node, :all.count, {:limit => limit, :offset => offset, :order => :start_node})
    start_node_sets = self.calculate_start_node_sets_by_limit(start_nodes, start_node_limit)
    while !start_nodes.empty?
      start_node_sets.each do |start_node_set|
        conditional = conditional.merge({:start_node => start_node_set})
        self.generate_gexf(fs, graph, conditional)
        self.generate_graphml(fs, graph, conditional)
      end
      start_nodes = graph.edges.aggregate(:start_node, :all.count, {:limit => limit, :offset => offset, :order => :start_node})
      start_node_sets = self.calculate_start_node_sets_by_limit(start_nodes, start_node_limit)
    end
  end
  
  def self.calculate_start_node_sets_by_limit(start_nodes, start_node_limit)
    start_node_sets = []
    current_count = 0
    start_node_set = []
    start_nodes.each do |start_node, count|
      if current_count <= start_node_limit
        current_count += count
        start_node_set << start_node
      else
        start_node_sets << start_node_set
        current_count = count
        start_node_set = []
        start_node_set << start_node
      end
    end
    start_node_sets << start_node_set
    return start_node_sets
  end
  
  def self.derive_style_from_tweet(record)
    if record.in_reply_to_status_id
      return "retweet"
    else
      return "mention"
    end
  end
  
  # def self.run(curation_id, save_path)
  #   curation = Curation.find({:id => curation_id})
  #   retweet_graph = generate_graph({:style => "retweet", :title => "Network Map", :curation_id => curation_id})
  #   # #save into separate var in the unlikely case that there are not any retweets of any sort
  #   last_id_results = Database.result("select twitter_id from tweets"+Analysis.conditional(collection)+" and in_reply_to_screen_name != '' order by twitter_id desc limit 1")
  #   if !last_id_results.empty?
  #     overall_last_id = last_id_results.first.values.first
  #     last_id = 0
  #     num = 0
  #     finished = false
  #     while !finished
  #       query = "select screen_name,twitter_id,in_reply_to_status_id,created_at,in_reply_to_screen_name from tweets"+Analysis.conditional(collection)+" and in_reply_to_screen_name != ''"# and twitter_id > #{last_id} order by twitter_id asc limit #{MAX_ROW_COUNT_PER_BATCH}"
  #       @edges = []
  #       objects = Database.spooled_result(query)
  #       while row = objects.fetch_hash do
  #         edge = {}
  #         num+=1
  #         if row["in_reply_to_status_id"] == "0"
  #           edge["style"] = "mention"
  #         else
  #           edge["style"] = "retweet"
  #         end
  #         edge["start_node"] = row["in_reply_to_screen_name"]
  #         edge["end_node"] = row["screen_name"]
  #         edge["edge_id"] = row["twitter_id"]
  #         edge["time"] = row["created_at"]
  #         edge["graph_id"] = retweet_graph.id
  #         edge["collection_id"] = collection_id
  #         puts "Edge: FROM: #{edge["start_node"]} TO: #{edge["end_node"]} ID: #{edge["edge_id"]}"
  #         @edges << edge
  #         last_id = edge["edge_id"]
  #         if last_id.to_i == overall_last_id
  #           finished = true
  #         end
  #         if @edges.length >= MAX_ROW_COUNT_PER_BATCH
  #           Database.update_all({:edges => @edges}, Environment.new_db_connect)
  #           @edges = []
  #         end
  #       end
  #     end
  #     objects.free
  #     Database.terminate_spooling  
  #     Database.update_all({"edges" => @edges})
  #     @edges.clear
  #   end
  #   retweet_graph.written = true
  #   retweet_graph.save
  #   generate_graphml_files(curation, save_path, retweet_graph)
  #   FilePathing.push_tmp_folder(save_path)
  # end
  # 
  # def self.generate_graphml_files(curation, save_path, graph)
  #   granularity = "hour"
  #   time_queries = resolve_time_query(granularity)
  #   time_queries.each_pair do |granularity, time_query|
  #     edge_timeline = Database.result("select date_format(time, '#{time_query}') as time from edges where graph_id = #{graph.id} group by date_format(time, '#{time_query}') order by time desc")
  #     edge_timeline.each do |time_set|
  #       time, hour, date, month, year = resolve_time(granularity, time_set["time"])
  #       sub_folder = [year, month, date, hour].join("/")
  #       tmp_folder = FilePathing.tmp_folder(curation, sub_folder)
  #       query = "select * from edges where "+Analysis.time_conditional("time", time_set["time"], granularity)+" and graph_id = #{graph.id}"
  #       Graphml.generate_file(query, "full", tmp_folder)
  #     end
  #   end
  # end
end
