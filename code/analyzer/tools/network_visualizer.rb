class NetworkVisualizer < AnalysisMetadata
  
  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    return false if !self.requires(@analysis_metadata, {:function => "conversational_network_graph"})
    curation = @analysis_metadata.curation
    Sh::filestore_get("/gexf/", ENV["TMP_PATH"], "curation_#{curation.id}_#{@analysis_metadata.id}.gexf")
    resource = RestClient::Resource.new(
      "http://178.79.169.159:23672/gephi_export",
      :timeout => -1)
    response = resource.post :data =>  File.new(ENV["TMP_PATH"]+"curation_#{curation.id}_#{@analysis_metadata.id}.gexf")
    file = File.open(ENV["TMP_PATH"]+"curation_#{curation.id}_#{@analysis_metadata.id}.gexf", "w")
    file.write(response)
    file.close
    Sh::filestore_send(ENV["TMP_PATH"], "/gexf_layouts/", "curation_#{curation.id}_#{@analysis_metadata.id}.gexf")
    Sh::rm(ENV["TMP_PATH"]+"curation_#{curation.id}_#{@analysis_metadata.id}.gexf")
    return true
  end
  
end

