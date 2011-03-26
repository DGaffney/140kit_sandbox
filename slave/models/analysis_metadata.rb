class AnalysisMetadata
  include DataMapper::Resource
  property :id,   Serial
  property :finished, Boolean, :default => false
  property :rest, Boolean, :default => false
  property :curation_id, Integer, :unique_index => [:unique_metadata]
  property :analytical_offering_id, Integer, :unique_index => [:unique_metadata]
  belongs_to :curation, :child_key => :curation_id
  belongs_to :analytical_offering, :child_key => :analytical_offering_id
  has n, :analytical_offering_variables
  
  def display_terminal
    display = ""
    info = get_info
    display+="Function: #{info[:function]} Language: #{info[:language]}\nVariables:\n----------"
    info[:variables].each do |var|
      display+="\n  Name: #{var[:name]} Kind: #{var[:kind]} Value: #{var[:value]}"
    end
    return display
  end

  def get_info
    info = {:function => function, :language => language, :variables => []}
    analytical_offering_variables.each do |var|
      info[:variables] << {:name => var.name, :kind => var.kind, :value => var.value}
    end
    return info
  end
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
  
  def clear
    function_class.clear(self)
  end
  
  def self.clear
    self.destroy
  end
  
  def self.function
    return self.underscore
  end
  def self.push_tmp_folder(folder_name, folder=ENV['TMP_PATH'])
    folder = (folder+"/"+self.underscore).gsub("//", "/")
    FilePathing.push_tmp_folder(folder_name, folder)
  end

  def self.remove_permanent_folder(folder_name, folder=ENV['TMP_PATH'])
    folder = (folder+"/"+self.underscore).gsub("//", "/")
    FilePathing.remove_permanent_folder(folder_name, folder)
  end
  
  def self.finalize(curation)
    response = self.finalize_analysis(curation)
    response[:researcher_id] = curation.researcher.id
    Mail.queue(response)
    debugger
    analysis_metadata = curation.analysis_metadatas.select{|x| x.function == self.function}.first
    analysis_metadata.update(:finished => true)
  end
  
  def self.finalize_analysis(curation)
    response = {}
    response[:recipient] = curation.researcher.email
    response[:subject] = "#{curation.researcher.user_name}, an analytical process on your '#{curation.name}' data has finished."
    response[:message_content] = "An analytical process, #{self}, has finished running on your dataset. You can view results by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
    return response
  end
end