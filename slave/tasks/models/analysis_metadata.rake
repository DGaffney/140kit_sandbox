namespace :analysis_metadata do 
  def select_analysis_metadata(curation)
    answer = Sh::clean_gets_yes_no("Currently there are #{AnalyticalOffering.count} Analytical processes available. See names?", "Sorry, one more time:")
    if answer
      puts "Analytical Processes: #{AnalyticalOffering.all.collect{|ao| "#{ao.title} (function: #{ao.function})"}.sort.join("\n")}"
      puts "To see a description of a process, enter the function name like this: 'man function_name'"
      puts "To add a process, enter the function name like this: 'add function_name'"
      puts "To complete the process, type 'finish'"
    end
    answer = Sh::clean_gets
    while answer!="finish"
      if answer[0..2]=="man"
        analytical_offering = AnalyticalOffering.first(:function => answer.gsub("man ", ""))
        if analytical_offering
          puts analytical_offering.description
          analytical_offering.variables.each do |aov|
            puts "\t"+aov.name+": "+aov.description
          end
        else
          puts "Sorry, something was screwy in finding that function. Try again."
        end
      elsif answer[0..2]=="add"
        analytical_offering = AnalyticalOffering.first(:function => answer.gsub("add ", ""))
        if analytical_offering
          analysis_metadata = AnalysisMetadata.new
          analysis_metadata.analytical_offering_id = analytical_offering.id
          analysis_metadata.curation = curation
          analysis_metadata.save
          create_analysis_metadata(analysis_metadata, curation)
          puts "Added #{answer} to curation. #{curation.analysis_metadatas.length} total analytics now tacked on. To remove, type 'remove function_name'"
        else
          puts "Sorry, something was screwy in finding that function. Try again."
        end
      elsif answer[0..5]=="remove"
        analytical_offering = AnalyticalOffering.first(:function => answer.gsub("remove ", ""))
        if analytical_offering
          analysis_metadata = AnalysisMetadata.first(:curation_id => curation.id, :function => analytical_offering.function)
          analysis_metadata.destroy
          curation.analysis_metadatas = curation.analysis_metadatas-[analysis_metadata]
          puts "Removed #{answer} from curation. #{curation.analysis_metadatas.length} total analytics now tacked on. To add, type 'add function_name'"
        else
          puts "Sorry, something was screwy in finding that function. Try again."
        end
      else puts "Command not recognized. Try again."
      end
      answer = Sh::clean_gets
    end
  end

  def create_analysis_metadata(analysis_metadata, curation)
    analysis_metadata.set_variables(curation).each do |variable|
      puts "Name: "+variable.name
      puts "Description: "+variable.description
      puts "Data Type: "+variable.kind
      puts "Enter your variable now, or type 'cancel' to cancel adding this analytical process."
      answer = Sh::clean_gets
      if answer!="cancel"
        response = analysis_metadata.verify_variable(variable, answer, curation)
        while !response[:reason].empty?
          puts response[:reason]
          answer = Sh::clean_gets
          response = analysis_metadata.verify_variable(variable, answer, curation)
        end
        analytical_offering_variable = AnalyticalOfferingVariable.new
        analytical_offering_variable.value = response[:variable]
        analytical_offering_variable.analytical_offering_variable_descriptor = variable
        analytical_offering_variable.analysis_metadata = analysis_metadata
        analytical_offering_variable.save
      else
        analysis_metadata.destroy
        break
      end
    end
  end
end