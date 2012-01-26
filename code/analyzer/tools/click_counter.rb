class ClickCounter < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000

  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id)
    curation = Curation.first(:id => curation_id)
    FilePathing.tmp_folder(curation, self.underscore)
    conditional = Analysis.curation_conditional(curation)
    graph = Graph.first_or_create(:title => "click_count", :style => "histogram", :analysis_metadata_id => self.analysis_metadata(curation)&&self.analysis_metadata(curation).id, :curation_id => curation.id)
    limit = DEFAULT_CHUNK_SIZE||1000
    offset = 0
    click_domains = Click.aggregate(:hh)
    click_domain_like_statement = click_domains.collect{|click_domain| "value like 'http://#{click_domain}/_%'"}.join(" or ")
    full_select_without_limit_offset = "select * from entities where (#{click_domain_like_statement}) and #{Analysis.conditions_to_mysql_query(conditional)}"
    sub_directory = "/"+[graph.year,graph.month,graph.date,graph.hour].compact.join("/")
    path = ENV['TMP_PATH']
    full_path_with_file = sub_directory == "/" ? path+"/"+graph.title+".csv" : path+sub_directory+"/"+graph.title+".csv"
    Sh::mkdir(path+sub_directory) if sub_directory != "/"
    FasterCSV.open(full_path_with_file, "w") do |csv|
      records = DataMapper.repository.adapter.select(full_select_without_limit_offset+" limit #{limit} offset #{offset}")
      csv << ["label", "value"]
      while !records.empty?
        graph_points = []
        records.each do |entity|
          hh = entity.value.scan(/http:\/\/(.*)\/./).flatten.first&&entity.value.scan(/http:\/\/(.*)\/./).flatten.first.gsub("'", "")
          h = entity.value.scan(/http:\/\/.*\/(.*)/).flatten.first&&entity.value.scan(/http:\/\/.*\/(.*)/).flatten.first.scan(/\w*/).flatten.first.gsub("'", "")
          click_count = DataMapper.repository.adapter.select("select count(*) from clicks where hh = '#{hh}' and binary h = '#{h}'").first
          if click_count>0
            graph_point = {:label => entity.value.scan(/(http:\/\/.*\/\w*)/).flatten.first, :value => click_count, :analysis_metadata_id => graph.analysis_metadata_id, :curation_id => curation.id, :graph_id => graph.id}
            graph_points << graph_point
            csv << [graph_point[:label],graph_point[:value]]
          end
        end
        GraphPoint.save_all(graph_points)
        offset+=limit
        records = DataMapper.repository.adapter.select(full_select_without_limit_offset+" limit #{limit} offset #{offset}")
      end
    end
    graph.written = true
    graph.save!
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the raw Click data for the  click counter in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end
