module Analysis::Dependencies
  def self.method_missing(method_name, *args)
    analytical_offering_functions = AnalyticalOffering.all(:language => "ruby").collect{|ao| ao.function}
    if analytical_offering_functions.include?(method_name.to_s)
      if self.respond_to?(method_name.to_s+"_dependencies")
        dependencies = Analysis::Dependencies.send(method_name.to_s+"_dependencies")
        dependencies.each do |dependency|
          require dependency
        end
        puts "Required #{dependencies.length} dependencies:"
        puts dependencies.join(", ")
        return dependencies
      else
        return "No dependencies defined."
      end
    else
      super
    end
  end
  
  def self.compact_language_detection_dependencies
    ['cld']
  end
  
  def self.semantic_analyzer_dependencies
    ['stemmer', 'semantic']
  end
    
end
