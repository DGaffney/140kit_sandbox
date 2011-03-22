class AnalysisMetadata < Model
  include DataMapper::Resource
  property :id,   Serial
  property :finished, Boolean, :default => false
  property :rest, Boolean, :default => false
  property :curation_id, Integer, :unique_index => [:unique_metadata]
  property :analytical_offering_id, Integer, :unique_index => [:unique_metadata]
  belongs_to :curation, :child_key => :curation_id
  belongs_to :analytical_offering, :child_key => :analytical_offering_id
  has n, :analytical_offering_variables
  
  def method_missing(method_name, *args)
    if variables.include?(method_name)
    else
      super
    end
  end

  def analytical_offering_variable_descriptions
    #placeholder code - Analytical Offerings will be those files in tools, 
    #which will be subclasses of AnalyticalOffering. Each of these can define this array, which 
    #will contain the correctly ordered hashes each having a {:description,:example,:variable_name,:position} field.
    #optionally, each variable can have a process for fixing itself. This can be achieved by overriding 
    #method_missing in the super class, here, and then only returning blank if the variable does not actually 
    #have one and it is a named variable- otherwise super the method_missing
    return []
  end
  
  def run_vars
    return variables.collect{|v| v.value.inspect}
  end
  def variables
    return analytical_offering_variables.sort{|x,y| x.position<=>y.position}
  end
  
  def set_variables(curation)
    remaining_variables = []
    case analytical_offering.language
    when "ruby"
      remaining_variables = function_class.set_variables(self, self.curation)
    end
    return remaining_variables
  end
  
  def self.set_variables(curation)
    return []
  end
  
  def verify_variable(variable_descriptor, answer, curation)
    verification = function_class.verify_variable(self, variable_descriptor, answer, curation)
  end
  
  def self.verify_variable(variable_descriptor, answer, curation)
    return {:variable => answer}
  end
  
  def language
    return analytical_offering.language
  end
  
  def function
    return analytical_offering.function
  end
  
  def function_class
    return function.to_class
  end
  
  def self.push_tmp_folder(folder_name, folder=ENV['TMP_PATH'])
    folder = (folder+"/"+self.underscore.chop).gsub("//", "/")
    FilePathing.push_tmp_folder(folder_name, folder)
  end
end