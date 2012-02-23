#for size counter to work, you will need to add the analytical offering and the analytical offering variable decriptors for it - generally, these are added in config/seed.rb (data objects that should be in every database), but for us, we'll just place them up here commented out:
# size_counter = AnalyticalOffering.create(:title => "Size Counter", :function => "size_counter", :language => "ruby", :created_by => "140kit Team", :created_by_link => "http://140kit.com", :access_level => "user", :description => "Tells you the number of users/tweets/entities in the dataset.")
# size_counter_var_0 = AnalyticalOfferingVariableDescriptor.create(:name => "curation_id", :position => 0, :kind => "integer", :analytical_offering_id=> size_counter.id, :description => "Curation ID for set to be analyzed")
# These lines below have to be called so that the size counter algorithm gets the variables set. normally, this goes through a separate workflow, but this is just an example, so you can plug these in directly. All these lines can be executed via running "rake load" in console while in the slave/ directory.
# curation = Curation.first
# size_counter_analysis_metadata = AnalysisMetadata.create(:curation_id => curation.id, :analytical_offering_id => size_counter.id)
# size_counter_analysis_metadata.set_variables(curation)


class SizeCounter < AnalysisMetadata

  DEFAULT_CHUNK_SIZE = 1000
  
  #Results: Frequency Charts of basic data on Tweets and Users per data set
  def self.run(curation_id)
    curation = Curation.first(:id => curation_id)
    #here I define a conditional. It's just a helper to get a hash I don't want to figure out every time. In this case, its going to look like: {:dataset_id => 1}
    conditional = Analysis.curation_conditional(curation)
    #I grab the analysis metadata to tag the graph points so I could, say, see what analysis processes people tend to be using.
    analysis_metadata = self.analysis_metadata(curation)
    FilePathing.tmp_folder(curation, self.underscore)
    graph = Graph.new
    graph.title = "Basic Dataset Counts"
    graph.curation_id = curation.id
    graph.analysis_metadata_id = analysis_metadata.id
    graph.style = "histogram"
    graph.save!
    graph_points = []
    #create three graph points, store into an array so i can create a csv of them.
    graph_points << GraphPoint.create(:label => "Total Tweets", :value => Tweet.count(conditional), :analysis_metadata_id => analysis_metadata.id, :curation_id => curation.id, :graph_id => graph.id)
    graph_points << GraphPoint.create(:label => "Total Users", :value => User.count(conditional), :analysis_metadata_id => analysis_metadata.id, :curation_id => curation.id, :graph_id => graph.id)
    graph_points << GraphPoint.create(:label => "Total Entities", :value => Entity.count(conditional), :analysis_metadata_id => analysis_metadata.id, :curation_id => curation.id, :graph_id => graph.id)
    #ENV['TMP_PATH'] is set elsewhere. basically, its /slave/tmp_files/a09cb0e9fd9a0b0f90ab0cd01249/size_counter, which is just a unique dir to serve as temp storage for my data.
    file_name_with_path = ENV['TMP_PATH']+"/size_count.csv"
    #here i am calling upon faster_csv, which is a gem. I add gems under the slave/analyzer/dependencies.rb file, which is called directly before running the analytic. 
    #This keeps dependencies easily identifiable and cleanly  written rather than splattered on the top of each of these files.
    FasterCSV.open(file_name_with_path, "w") do |csv|
      csv << ["label", "value"]
      graph_points.each do |graph_point|
        csv << [graph_point.label, graph_point.value]
      end
    end
    self.push_tmp_folder(curation.stored_folder_name)
    self.finalize(curation)
  end

  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, the raw Graph data for the basic histograms in the \"#{curation.name}\" data set is complete."
    response[:message_content] = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end
