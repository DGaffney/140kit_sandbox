describe AnalysisMetadata do
  before :each do
    curation = Curation.gen
    curation.save!
  end
  
  it "should display_terminal correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    AnalysisMetadata.last.display_terminal.class.should == String
    AnalysisMetadata.destroy
  end
  
  it "should get_info correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.get_info.class.should == Hash
    AnalysisMetadata.destroy
  end
  
  it "should return analytical_offering_variable_descriptions" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.analytical_offering_variable_descriptions.class.should == Array
    AnalysisMetadata.destroy
  end
  
  it "should return run_vars correctly" do 
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.run_vars.class.should == Array
    AnalysisMetadata.destroy
  end
  
  it "should return variables correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.variables.class.should == Array
    AnalysisMetadata.destroy
  end
  
  it "should verify_variables correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.verify_variable( AnalyticalOfferingVariableDescriptor.first, "2", Curation.first).class.should == Hash
    AnalysisMetadata.destroy
  end

  it "should verify_variables at class level correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.set_variables(Curation.first)
    AnalysisMetadata.verify_variable(analysis_metadata, AnalyticalOfferingVariableDescriptor.first, "2", Curation.first).class.should == Hash
    AnalysisMetadata.destroy
  end

  it "should return the language correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.language.class.should == String
    AnalysisMetadata.destroy
  end
  
  it "should return the function name correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.function.class.should == String
    AnalysisMetadata.destroy
  end
  
  it "should return the function_class correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.function_class.should == analysis_metadata.function.to_class
    AnalysisMetadata.destroy
  end
  
  it "should clear properly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.clear.should == true
    AnalysisMetadata.destroy
  end
  
  it "should return an analysis_metadata at the class level" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.function_class.analysis_metadata(analysis_metadata.curation).should == analysis_metadata
    AnalysisMetadata.destroy
  end
  
  it "should return the function at the class level" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.function_class.function.should == analysis_metadata.function
    AnalysisMetadata.destroy
  end
  
  it "should push_tmp_folders at the class level" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.function_class.push_tmp_folder('tmp').should == ""
    AnalysisMetadata.destroy
  end
  
  it "should remove_permanent_folder at the class level" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.function_class.remove_permanent_folder('tmp').should == nil
    AnalysisMetadata.destroy
  end
  
  it "should finalize at the class level" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.function_class.finalize(analysis_metadata.curation).should == true
    AnalysisMetadata.destroy
  end
  
  it "should finalize_analysis at the class level" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    AnalysisMetadata.last.function_class.finalize_analysis(AnalysisMetadata.last.curation).class.should == Hash
    AnalysisMetadata.destroy
  end
  
end