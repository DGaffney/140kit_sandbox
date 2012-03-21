class BasicUserStatistic < AnalysisMetadata
  # include ActsAsReloadable
  DEFAULT_CHUNK_SIZE = 1000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    self.generate_stats(curation)
  end

  def self.generate_stats(curation)
    graph = Graph.first_or_create({:title => "basic_user_statistics", :style => "histogram", :curation_id => @analysis_metadata.curation_id, :analysis_metadata_id => @analysis_metadata.id})
    limit = 1000
    offset = 0
    datapoints = {:followers_count => [], :friends_count => [], :statuses_count => [], :listed_count => [], :favourites_count => []}
    users = User.all(:limit => limit, :offset => offset, :dataset_id => curation.datasets.collect{|d| d.id})
    while !users.empty?
      users.each do |user|
        datapoints[:followers_count] << user.followers_count
        datapoints[:friends_count] << user.friends_count
        datapoints[:statuses_count] << user.statuses_count
        datapoints[:listed_count] << user.listed_count
        datapoints[:favourites_count] << user.favourites_count
      end
      users = User.all(:limit => limit, :offset => offset, :dataset_id => curation.datasets.collect{|d| d.id})
      offset+=limit
    end
    results = []
    datapoints.each_pair do |variable, values|
      results << {:label => "#{variable.to_s}_standard_deviation", :value => values.standard_deviation, :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_average", :value => values.average, :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_sum", :value => values.sum, :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_n", :value => values.length, :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_sample_variance", :value => values.sample_variance, :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_0_percentile", :value => values.percentile(0.0), :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_25_percentile", :value => values.percentile(0.25), :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_50_percentile", :value => values.percentile(0.50), :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_75_percentile", :value => values.percentile(0.75), :graph_id => graph.id, :curation_id => graph.curation_id}
      results << {:label => "#{variable.to_s}_100_percentile", :value => values.percentile(1.0), :graph_id => graph.id, :curation_id => graph.curation_id}
    end
    GraphPoint.save_all(results)
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the raw Graph data for the basic histograms in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "DOWNLOAD!"
    return response
  end
end
