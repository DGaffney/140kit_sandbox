class AnalyticalOffering < ActiveRecord::Base
  has_many :analysis_metadatas
  has_many :analytical_offering_variable_descriptors
  has_many :analytical_offering_variables
  
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
  
  def self.already_applied(curation)
    already_applied_analytics = []
    applied_analytics = curation.analysis_metadatas.collect(&:analytical_offering)
    applied_analytics.each do |applied_analytic|
      already_applied_analytics << applied_analytic if applied_analytic.analytical_offering_variable_descriptors.select{|x| x.user_modifiable}.empty?
    end
    return already_applied_analytics
  end
  
  def applied(curation)
    curation.analysis_metadatas.collect(&:analytical_offering).include?(self)
  end
  
  def analysis_metadata(curation)
    return AnalysisMetadata.where(:curation)
  end
end
