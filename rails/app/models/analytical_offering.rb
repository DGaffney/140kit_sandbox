class AnalyticalOffering < ActiveRecord::Base
  has_many :analysis_metadatas
  has_many :analytical_offering_variable_descriptors
  has_many :analytical_offering_variables
  has_many :analytical_offering_requirements
  
  def self.available_to_researcher(researcher)
    access_levels = Researcher.roles[0..Researcher.roles.index(researcher.role)]
    return AnalyticalOffering.where(:enabled => true, :access_level => access_levels)
  end
  
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

  def dependencies
    return analytical_offering_requirements.sort{|x,y| x.position<=>y.position}
  end
  
  def self.already_applied(curation)
    already_applied_analytics = []
    applied_analytics = curation.analysis_metadatas.collect(&:analytical_offering)
    applied_analytics.each do |applied_analytic|
      already_applied_analytics << applied_analytic if applied_analytic.variables.select{|x| x.user_modifiable}.empty?
      if applied_analytic.analytical_permutations != 1 && applied_analytic.analytical_permutations != -1
        already_applied_analytics << applied_analytic if applied_analytics.select{|analytic| analytic == applied_analytic}.length == applied_analytic.analytical_permutations
      end
    end
    return already_applied_analytics.uniq
  end
  
  def applied(curation)
    curation.analysis_metadatas.collect(&:analytical_offering).include?(self)
  end
  
  def analysis_metadata(curation)
    return AnalysisMetadata.where(:curation)
  end
  
  def analytical_permutations
    return 1 if self.variables.empty?
    return -1 if !self.variables.collect(&:kind).include?("enum")
    permutations = 1
    enumerable_group = self.variables.select{|x| permutations = permutations*x.values.split(",").length if x.kind == "enum"}
    return permutations
  end
end
