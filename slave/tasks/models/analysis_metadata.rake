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
          stored = analysis_metadata.verify_uniqueness
          if stored
            puts "Added #{answer.gsub("add ", "")} to curation. #{curation.analysis_metadatas.length} total analytics now tacked on. To remove, type 'remove function_name'" 
          else
            puts "Failed to add #{answer.gsub("add ", "")} to curation. #{curation.analysis_metadatas.length} total analytics now tacked on. To remove, type 'remove function_name'" 
          end
        else
          puts "Sorry, something was screwy in finding that function. Try again."
        end
      elsif answer[0..5]=="remove"
        remove_analysis_metadata(answer, curation)
      else puts "Command not recognized. Try again."
      end
      answer = Sh::clean_gets
    end
  end

  def create_analysis_metadata(analysis_metadata, curation)
    analysis_metadata.set_variables.each do |variable|
      puts "Name: "+variable.name
      puts "Description: "+variable.description
      puts "Data Type: "+variable.kind
      inspected_value = (variable.value.nil?||variable.value.class!=String) ? variable.value.inspect : variable.value
      puts "Current value: "+inspected_value
      puts "Enter your variable now, press enter to select default, or type 'cancel' to cancel adding this analytical process."
      answer = Sh::clean_gets
      if answer!="cancel"
        response = analysis_metadata.verify_variable(variable, answer)
        while !response[:reason].nil? && !response[:reason].empty?
          puts response[:reason]
          answer = Sh::clean_gets
          response = analysis_metadata.verify_variable(variable, answer)
        end
        variable.value = response[:variable]
      else
        analysis_metadata.destroy
        break
      end
      variable.save
    end
  end
  
  def remove_analysis_metadata(answer, curation)
    analytical_offering = AnalyticalOffering.first(:function => answer.gsub("remove ", ""))
    if analytical_offering
      analysis_metadatas = AnalysisMetadata.all(:curation_id => curation.id, :analytical_offering_id => analytical_offering.id)
      puts "This curation has #{analysis_metadatas.length} instances of that analysis process. Review this list, then enter the ID of the analysis metadata you wish to destroy. Type 'cancel' to cancel the removal."
      analysis_metadatas.each do |analysis_metadata|
        puts "\n\tAnalysis Metadata: ID: #{analysis_metadata.id}; Variables: #{analysis_metadata.variables.collect{|variable| "\n\t\tVariable: #{variable.name}; Value: #{variable.value}"}}"
      end
      possible_answers = analysis_metadatas.collect{|analysis_metadata| analysis_metadata.id.to_s}
      answer = Sh::clean_gets
      while !possible_answers.include?(answer) && answer!="cancel"
        puts "Sorry, that was not one of the IDs specified. Please try again."
        answer = Sh::clean_gets
      end
      analysis_metadata = AnalysisMetadata.first(:id => answer)
      if answer!="cancel"
        analysis_metadata.clear
        curation.analysis_metadatas = curation.analysis_metadatas-[analysis_metadata]
        puts "Removed #{answer} from curation. #{curation.analysis_metadatas.length} total analytics now tacked on. To add, type 'add function_name'"
      end
    else
      puts "Sorry, something was screwy in finding that function. Try again."
    end
  end
end