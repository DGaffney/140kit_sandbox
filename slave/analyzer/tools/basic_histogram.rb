class BasicHistogram < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id)
    curation = Curation.first(:id => curation_id)
    FilePathing.tmp_folder(curation, self.underscore)
    self.generate_graphs([
      {:model => Tweet, :attribute => :language},
      {:model => Tweet, :attribute => :created_at},
      {:model => Tweet, :attribute => :source},
      {:model => Tweet, :attribute => :location},
      {:model => User,  :attribute => :followers_count},
      {:model => User,  :attribute => :friends_count},
      {:model => User,  :attribute => :favourites_count},
      {:model => User,  :attribute => :geo_enabled},
      {:model => User,  :attribute => :statuses_count},
      {:model => User,  :attribute => :lang},
      {:model => User,  :attribute => :time_zone},
      {:model => User,  :attribute => :created_at}
    ], curation)
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.generate_graphs(frequency_set, curation, analytic=self)
    frequency_set = [frequency_set].flatten
    curation_id = curation && curation.id || nil
    graphs = []
    frequency_set.each do |fs|
      fs[:style] = fs[:style] || "histogram"
      fs[:title] = fs[:title] || fs[:model].pluralize+"_"+fs[:attribute].to_s
      fs[:conditional] = fs[:conditional] || {}
      fs[:generate_graph_points] = fs[:generate_graph_points] || true
      fs[:override_conditional] = fs[:override_conditional] || false
      graph = nil
      if fs[:generate_graph_points]
        graph_attrs = Hash[fs.select{|k,v| Graph.attributes.include?(k)}]
        graph = Graph.first_or_create({:curation_id => curation_id, :analysis_metadata_id => analytic.analysis_metadata(curation).id}.merge(graph_attrs))
        graph.graph_points.destroy #can't call .new? as a condition for this, as it's created now.
        graph.edges.destroy #can't call .new? as a condition for this, as it's created now.
        conditional = fs[:override_conditional] ? fs[:conditional] : Analysis.curation_conditional(curation).merge(fs[:conditional])
        graphs << graph
      end
      if block_given?
        yield fs, graph, conditional
      else
        self.frequency_graphs(fs, graph, conditional)
      end
    end
    return graphs
  end

  def self.frequency_graphs(fs, graph, conditional, path=ENV['TMP_PATH'])
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    sub_directory = "/"+[fs[:year],fs[:month],fs[:date],fs[:hour]].compact.join("/")
    full_path_with_file = sub_directory == "/" ? path+"/"+fs[:title]+".csv" : path+sub_directory+"/"+fs[:title]+".csv"    
    Sh::mkdir(path+sub_directory) if sub_directory != "/"
    FasterCSV.open(full_path_with_file, "w") do |csv|
      if block_given?
        yield fs, graph, conditional, csv, limit, offset
      else
        records = fs[:model].aggregate(fs[:attribute], :all.count, {:limit => limit, :offset => offset}.merge(conditional))
        while !records.empty?
          graph_points = records.collect{|record| {:label => record.first, :value => record.last, :graph_id => graph.id, :curation_id => graph.curation_id}}
          graph_points = graph.sanitize_points(graph_points)
          GraphPoint.save_all(graph_points) if fs[:generate_graph_points]
          csv << ["label", "value"]
          graph_points.each do |graph_point|
            csv << [graph_point[:label],graph_point[:value]]
          end
          offset+=limit
          records = fs[:model].aggregate(fs[:attribute], :all.count, {:limit => limit, :offset => offset}.merge(conditional))
        end
      end
    end
    graph.written = true
    graph.save!
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the raw Graph data for the basic histograms in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end
