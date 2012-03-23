class AnalysisMetadata
  include DataMapper::Resource
  storage_names[:default] = 'analysis_metadatum'
  property :id,   Serial
  property :finished, Boolean, :default => false
  property :rest, Boolean, :default => false
  property :curation_id, Integer
  property :analytical_offering_id, Integer
  property :ready, Boolean
  belongs_to :curation, :child_key => :curation_id
  belongs_to :analytical_offering, :child_key => :analytical_offering_id
  has n, :analytical_offering_variables
  has n, :graphs
  has n, :graph_points
  has n, :edges
  
  def curation
    Curation.first(:id => curation_id)
  end

  def verify_uniqueness
    duplicate_analysis_metadatas = AnalysisMetadata.all(:curation_id => self.curation_id, :analytical_offering_id => self.analytical_offering.id, :finished => false).select{|analysis_metadata| analysis_metadata.run_vars==self.run_vars}-[self]
    if !duplicate_analysis_metadatas.empty?
      puts "Found an exact duplicate of this analysis metadata. This one will now be deleted. Only one analysis metadata of exact variables is permitted at a time."
      self.variables.collect{|variable| variable.destroy}
      self.curation.analysis_metadatas = self.curation.analysis_metadatas-[self]
      self.destroy
    end
    return duplicate_analysis_metadatas.empty?
  end
  
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
    return variables.collect{|v| v.value}
  end
  
  def variables
    return analytical_offering_variables.sort{|x,y| x.position<=>y.position}
  end
  
  def set_variables
    variables = []
    case language
    when "ruby"
      analytical_offering.variables.each do |variable|
        analytical_offering_variable = AnalyticalOfferingVariable.new
        analytical_offering_variable.analytical_offering_variable_descriptor_id = variable.id
        analytical_offering_variable.analysis_metadata_id = self.id
        analytical_offering_variable.value = set_variable(analytical_offering_variable)
        variables << analytical_offering_variable
      end
    end
    return variables
  end
  
  def set_variables!
    self.set_variables.each do |v|
      v.value = self.function_class.default_variables[self.set_variables.index(v)] if v.value.nil?
      v.save!
    end
  end
  
  def set_variable(analytical_offering_variable)
    case analytical_offering_variable.name
    when "curation_id"
      return curation_id
    else
      function_class.set_variables(self, analytical_offering_variable, Curation.first(curation_id))
    end
  end

  def self.set_variables(analysis_metadata, analytical_offering_variable, curation)
    return nil
  end
  
  def verify_variable(analytical_offering_variable, answer)
    case analytical_offering_variable.name
    when "curation_id"
      answer = answer.empty? ? self.curation_id : answer.to_i
      response = {}
      response[:reason] = "The curation id you specified (#{answer}) does not correspond to an existing curation. Please try again."
      response[:variable] = answer
      return response if Curation.first(:id => answer).nil?
    else
      return function_class.verify_variable(self, analytical_offering_variable, answer).merge({:analytical_offering_variable_descriptor_id => analytical_offering_variable.id})
    end
    return {:variable => answer, :analytical_offering_variable_descriptor_id => analytical_offering_variable.id}
  end
  
  def self.verify_variable(metadata, variable_descriptor, answer)
    #if it got sent here, then it means that the analytical offering has not determined its own independent
    #verification process for the given variable.
    return {:variable => answer}
  end
  
  def self.default_variables
    []
  end

  def language
    return analytical_offering.language
  end
  
  def function
    return analytical_offering.function
  end
  
  def function_class
    begin
      return function.to_class
    rescue
      require "#{File.dirname(__FILE__)}/../analyzer/tools/#{function}.rb"
      retry
    end
  end
  
  def clear
    function_class.clear(self)
  end
  
  # to implement this process, simply put this line where the analysis needs to be required in order to go any further:
  # return nil if !self.requires(self.analysis_metadata(curation), [{:function => "click_counter", :with_options => [curation_id]}], curation)
  def self.requires(analysis_metadata, dependencies_to_load)
    debugger
    dependencies_to_load = [dependencies_to_load].flatten
    dependencies_to_load.each do |d|
      d[:with_options] = [] if d[:with_options].nil?
    end
    curation = analysis_metadata.curation
    functions = dependencies_to_load.collect{|d| d[:function]}
    functions = "conversational_network_graph"
    dependent_analysis_metadatas = AnalyticalOffering.all(:function => functions).analysis_metadatas(:curation_id => curation.id, :finished => true)
    dependencies_met = dependent_analysis_metadatas.collect{|dam| {:function => dam.function, :with_options => dam.run_vars}}
    dependencies_needed = dependencies_to_load-dependencies_met
    required = dependencies_needed.empty?
    dependencies_needed.each do |dependency|
      analytical_offering = AnalyticalOffering.first(:function => dependency[:function])
      possibly_unfinished_analysis_metadatas = AnalysisMetadata.all(:curation_id => curation.id, :analytical_offering_id => analytical_offering.id, :finished => false)
      matches = !possibly_unfinished_analysis_metadatas.select{|puam| puam.run_vars == dependency[:with_options]}.empty?
      if !matches
        analysis_metadata = AnalysisMetadata.new(:curation_id => curation.id, :analytical_offering_id => analytical_offering.id, :finished => false, :ready => false)
        with_options_iterator = 0
        analytical_offering.analytical_offering_variable_descriptors.each do |descriptor|
          analytical_offering_variable = AnalyticalOfferingVariable.new
          analytical_offering_variable.analysis_metadata_id = analysis_metadata.id
          analytical_offering_variable.analytical_offering_variable_descriptor_id = descriptor.id
          analytical_offering_variable.value = dependency[:with_options][with_options_iterator]
          analytical_offering_variable.save!
          with_options_iterator+=1
        end
        analysis_metadata.ready = true
        analysis_metadata.save!
      end
    end
    if required
      puts "Required #{dependencies_to_load.length} dependent analytical offerings."
    else
      puts "Cannot run this analytic ('#{analysis_metadata.function}') yet - required analytics in place to run, but have not finished yet"
    end
    return required
  end
  
  def self.validates(conditional_set, this_analysis_metadata)
    if conditional_set.collect{|condition| condition.process.call(*condition.vars) }.compact.length==1 && conditional_set.first == true
      return true
    else
      conditional_set.each do |condition|
        if condition.process.call(*condition.vars) == false
          this_analysis_metadata.unlock!
          raise Exception, "Condition #{condition.name} failed for #{this_analysis_metadata.curation.name} curation on validation for #{this_analysis_metadata.function} function."
        end
      end
    end
  end
  
  def self.boot_out(curation=nil)
    analysis_metadata = self.analysis_metadata(curation)
    if analysis_metadata
      analysis_metadata.finished = false
      analysis_metadata.save!
      analysis_metadata.unlock!
      return analysis_metadata
    else
      return nil
    end
  end
  
  def self.analysis_metadata(curation)
    if $instance
      return $instance.metadata
    else
      return AnalyticalOffering.first(:function => self.underscore).analysis_metadatas.first(:curation_id => curation.id)
    end
  end
  
  def self.clear(analysis_metadata)
    analysis_metadata.graph_points.destroy
    analysis_metadata.graphs.destroy
    analysis_metadata.edges.destroy
    analysis_metadata.destroy
  end
  
  def self.function
    return self.underscore
  end
  
  def self.push_tmp_folder(folder_name, folder=ENV['TMP_PATH'])
    FilePathing.push_tmp_folder(folder_name, folder)
  end

  def self.remove_permanent_folder(folder_name, folder=ENV['TMP_PATH'])
    FilePathing.remove_permanent_folder(folder_name, folder)
  end
  
  # def self.finalize_work(curation)
  #   response = self.finalize_analysis(curation)
  #   response[:researcher_id] = curation.researcher.id
  #   Mail.queue(response)
  #   self.analysis_metadata(curation).update(:finished => true)
  #   self.analysis_metadata(curation).unlock!
  #   return response
  # end
  # 
  # def self.finalize_analysis(curation)
  #   response = {}
  #   response[:recipient] = curation.researcher.email
  #   response[:subject] = "#{curation.researcher.user_name}, an analytical process on your '#{curation.name}' data has finished."
  #   response[:message_content] = "An analytical process, #{self}, has finished running on your dataset. You can view results by visiting the collection's page: <a href=\"http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}\">http://140kit.com/#{curation.researcher.user_name}/collections/#{curation.id}</a>."
  #   return response
  # end
  
  def zip_download_url
    "http://"+STORAGE["path"]+"/"+self.curation.stored_folder_name
  end
end
