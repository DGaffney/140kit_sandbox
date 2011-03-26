class AnalyticalOffering
  ANALYTICAL_OFFERING_PATH = "analyzer/tools/"
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :index => [:unique_metadata]
  property :description, Text, :index => [:unique_metadata]
  property :function, String, :index => [:unique_analytical_offering]
  property :rest, Boolean, :index => [:unique_metadata], :default => false
  property :created_by, String, :index => [:unique_metadata]
  property :created_by_link, String, :index => [:unique_metadata]
  property :enabled, Boolean, :index => [:unique_metadata], :default => true
  property :language, String, :index => [:unique_analytical_offering]
  property :access_level, String, :index => [:unique_metadata]
  property :source_code_link, Text, :index => [:unique_metadata], :default => lambda {|ao, scl| Git::url_repo+ANALYTICAL_OFFERING_PATH+ao.function+AnalyticalOffering.language_extensions(ao.language)}
  has n, :analytical_offering_variable_descriptors
  
  def self.language_extensions(language)
    languages = {
      "ruby" => ".rb",
      "python" => ".py",
      "php" => ".php",
      "r" => ".r"
    }
    return languages[language]
  end
  
  def variables
    return analytical_offering_variable_descriptors.sort{|x,y| x.position<=>y.position}
  end
end