class NetworkVisualizer < AnalysisMetadata

  def self.verify_variable(metadata, analytical_offering_variable, answer)
    case analytical_offering_variable.name
    when "network_type"
      valid_responses = ["retweet", "mention", "combined"]
      response = {}
      response[:reason] = "You may only choose one of these options, and only these options (can't be left blank). You entered: #{answer}. You can choose from ['retweet','mention','combined']."
      response[:variable] = answer
      return response if !valid_responses.include?(answer)
    end
    return {:variable => answer}
  end
  
  def self.run(analysis_metadata_id, network_type)
    require 'rest-client'
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    return false if !self.requires(@analysis_metadata, {:function => "conversational_network_graph", :with_options => [network_type]})
    curation = @analysis_metadata.curation
    conversational_network_graph_analytical_offering = AnalyticalOffering.first(:function => "conversational_network_graph", :language => "ruby")
    dependent_analysis_metadata = AnalysisMetadata.all(:curation_id => curation.id, :analytical_offering_id => conversational_network_graph_analytical_offering.id).select{|x| x.variables.collect(&:value).include?(network_type)}.first
    Sh::filestore_get("/gexf/", ENV["TMP_PATH"], "curation_#{curation.id}_#{dependent_analysis_metadata.id}.gexf")
    resource = RestClient::Resource.new(
      "http://178.79.169.159:23672/gephi_export",
      :timeout => -1)
    response = resource.post :data =>  File.new(ENV["TMP_PATH"]+"curation_#{curation.id}_#{dependent_analysis_metadata.id}.gexf")
    file = File.open(ENV["TMP_PATH"]+"curation_#{curation.id}_#{@analysis_metadata.id}.gexf", "w")
    file.write(response)
    file.close
    Sh::filestore_send(ENV["TMP_PATH"], "/gexf_layouts/", "curation_#{curation.id}_#{@analysis_metadata.id}.gexf")
    Sh::rm(ENV["TMP_PATH"]+"curation_#{curation.id}_#{dependent_analysis_metadata.id}.gexf")
    Sh::rm(ENV["TMP_PATH"]+"curation_#{curation.id}_#{@analysis_metadata.id}.gexf")
    return true
  end
  
end

