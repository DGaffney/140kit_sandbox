class AnalysisMetadata < ActiveRecord::Base
  self.table_name = "analysis_metadatum"
  belongs_to :curation
  belongs_to :analytical_offering
  has_many :analytical_offering_variables
  has_many :graphs
  def status
    if self.finished
      return "Finished"
    elsif !self.ready && self.curation.status == "imported"
      return "Verifying"
    elsif self.ready && self.curation.status == "imported"
      return "Processing"
    elsif self.ready && self.curation.status == "tsv_stored"
      return "Waiting on Import"
    else return "Unknown"
    end
  end
  
  def links
    links = []
    if self.finished
      links << "<a href='/analytics/#{self.id}'>Results</a>"
    elsif !self.ready && self.curation.status == "imported"
      links << "<a href='/analytics/#{self.id}'>Results</a>"
    elsif self.ready && self.curation.status == "imported"
      links << "<a href='/analytics/#{self.id}'>Results</a>"
    end
  end

  def verify_absolute_uniqueness
    duplicate_analysis_metadatas = AnalysisMetadata.where(:curation_id => self.curation_id, :analytical_offering_id => self.analytical_offering.id, :finished => false).select{|analysis_metadata| analysis_metadata.run_vars==self.run_vars}-[self]
    results = {:success => true}
    if !duplicate_analysis_metadatas.empty?
      results[:reason] = "Found an exact duplicate of this analysis metadata. This one will now be deleted. Only one analysis metadata of exact variables is permitted at a time."
      results[:success] = false
      self.variables.collect{|variable| variable.destroy}
      self.curation.analysis_metadatas = self.curation.analysis_metadatas-[self]
      self.destroy
    end
    return results
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
        analytical_offering_variable.value = datamapper_dumped_object(set_variable(analytical_offering_variable))
        variables << analytical_offering_variable
      end
    end
    return variables
  end
  
  def datamapper_dumped_object(value)
    [ Marshal.dump(value) ].pack('m')
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
      function_class.set_variables(self, analytical_offering_variable, Curation.find_by_id(curation_id))
    end
  end

  def self.set_variables(analysis_metadata, analytical_offering_variable, curation)
    return ""
  end

  def verify_variable(analytical_offering_variable, answer)
    case analytical_offering_variable.name
    when "curation_id"
      answer = answer.empty? ? self.curation_id : answer.to_i
      response = {}
      response[:reason] = "The curation id you specified (#{answer}) does not correspond to an existing curation. Please try again."
      response[:variable] = answer
      return response if Curation.find_by_id(answer).nil?
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

  def title
    return analytical_offering.title
  end
  
  def language
    return analytical_offering.language
  end

  def created_by
    return analytical_offering.created_by
  end

  def created_by_link
    return analytical_offering.created_by_link
  end

  def source_code_link
    return analytical_offering.source_code_link
  end

  def function
    return analytical_offering.function
  end
  
  def function_class
    begin
      return function.to_class
    rescue
      require "#{File.dirname(__FILE__)}/../../../code/analyzer/tools/#{function}.rb"
      retry
    end
  end
  
  def function_path
    File.dirname(__FILE__) + "/../../../code/analyzer/tools/#{function}#{AnalyticalOffering.language_extensions(self.analytical_offering.language)}"
  end
  
  def clear
    function_class.clear(self)
  end
  
  def self.view(curation, params)
    return {:response => "<h1>Sorry!</h1><p>It looks like this developer has not created a viewable result for this analytic yet</p>", :found => false}
  end

end

require_all File.dirname(__FILE__) + '/../../../code/analyzer/tools'