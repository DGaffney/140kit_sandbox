class BasicHistogram < AnalysisMetadata

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

  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id, save_path)
    curation = Curation.first(:id => curation_id)
    self.generate_graph_points([
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

  def self.generate_graph_points(frequency_set, curation)
    frequency_set = [frequency_set].flatten
    curation_id = curation && curation.id || nil
    graphs = []
    frequency_set.each do |fs|
      # time, hour, date, month, year = resolve_time(fs["granularity"], fs["time_slice"])
      fs[:style] = fs[:style] || "histogram"
      fs[:title] = fs[:title] || fs[:model].pluralize+"_"+fs[:attribute].to_s
      graph_attrs = Hash[fs.select{|k,v| Graph.attributes.include?(k)}]
      graph = Graph.first_or_create({:curation_id => curation_id}.merge(graph_attrs))
      graphs << graph
      sub_folder = graph.folder_name
      tmp_folder = FilePathing.tmp_folder(curation, sub_folder)
      if block_given?
        yield fs, graph, tmp_folder
      else
        conditional = curation.nil? ? {} : Analysis.curation_conditional(curation)
        self.frequency_graphs(fs, graph, tmp_folder, conditional)
      end
    end
    return graphs
  end

  def self.frequency_graphs(fs, graph, tmp_folder, conditional)
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    FasterCSV.open(tmp_folder+graph.title+".csv", "w") do |csv|
      records = fs[:model].aggregate(fs[:attribute], :all.count, {:limit => limit, :offset => offset}.merge(conditional))
      while !records.empty?
        graph_points = []
        records.each do |record|
          csv << ["label", "value"]
          csv << record
          graph_points << {:label => record.first, :value => record.last, :graph_id => graph.id}
        end
        GraphPoint.save_all(GraphPoint.sanitize_points(graph, graph_points))
        offset+=limit
        records = fs[:model].aggregate(fs[:attribute], :all.count, {:limit => limit, :offset => offset}.merge(conditional))
      end
    end
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the raw Graph data for the basic histograms in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end
