class AnalysisMetadata
  include DataMapper::Resource
  property :id,   Serial
  property :function, String, :unique_index => [:unique_metadata]
  property :finished, Boolean, :default => false
  property :rest, Boolean, :default => false
  property :save_path, String, :default => lambda {|am, sp| "analytical_results/"+am.function.strip.downcase}
  property :curation_id, Integer, :unique_index => [:unique_metadata]
  belongs_to :curation, :child_key => :curation_id
  
  def analytical_offering_variable_descriptions
    #placeholder code - Analytical Offerings will be those files in tools, 
    #which will be subclasses of AnalyticalOffering. Each of these can define this array, which 
    #will contain the correctly ordered hashes each having a {:description,:example,:variable_name,:position} field.
    #optionally, each variable can have a process for fixing itself. This can be achieved by overriding 
    #method_missing in the super class, here, and then only returning blank if the variable does not actually 
    #have one and it is a named variable- otherwise super the method_missing
    return []
  end
  
end