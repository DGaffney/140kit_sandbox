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
    analysis_metadata.verify_variable( AnalyticalOfferingVariableDescriptor.first, "2").class.should == Hash
    AnalysisMetadata.destroy
  end

  it "should verify_variables at class level correctly" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    analysis_metadata.set_variables!
    AnalysisMetadata.verify_variable(analysis_metadata, AnalyticalOfferingVariableDescriptor.first, "2").class.should == Hash
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
    researcher = Researcher.first
    researcher = Researcher.gen if researcher.nil?
    researcher.save!
    curation = analysis_metadata.curation
    curation.researcher_id = researcher.id
    curation.save!
    researcher.save!
    analysis_metadata.function_class.finalize(analysis_metadata.curation).class.should == Hash
    AnalysisMetadata.destroy
  end
  
  it "should finalize_analysis at the class level where finalize is defined for analytic" do
    analysis_metadata = AnalysisMetadata.new(:curation_id => Curation.first.id, :analytical_offering_id => AnalyticalOffering.first.id, :finished => false, :rest => true)
    analysis_metadata.analytical_offering_id = 1
    analysis_metadata.save!
    AnalysisMetadata.last.function_class.finalize_analysis(AnalysisMetadata.last.curation).class.should == Hash
    AnalysisMetadata.destroy
  end
  
  it "should finalize_analysis at the class level where finalize is not defined for analytic" do
    curation = Curation.gen
    researcher = Researcher.gen
    curation.researcher_id = researcher.id
    curation.save!
    AnalysisMetadata.finalize_analysis(curation).class.should == Hash
  end
  
  it "should properly requires" do
    tweets = []
    entities = []
    users = []
    friendships = []
    dataset = Dataset.gen
    1.upto(100) do |gen_sample|
      tweet = Tweet.gen
      tweet.dataset_id = dataset.id
      tweet.save
      tweets << tweet
      entity = Entity.gen
      entity.dataset_id = dataset.id
      entity.save
      entities << entity
      user = User.gen
      user.dataset_id = dataset.id
      user.save
      users << user
      friendship = Friendship.gen
      friendship.dataset_id = dataset.id
      friendship.save
      friendships << friendship
    end
    curation = Curation.gen
    curation.datasets << dataset
    dataset.save
    curation.save
    am = AnalysisMetadata.gen
    am.curation_id = curation.id
    am.save!
    AnalysisMetadata.requires(am, [{:function => "basic_histogram", :with_options => [curation.id]}], curation).should == false
  end
  
  it "should properly validates" do
    am = AnalysisMetadata.gen
    AnalysisMetadata.validates([Struct::Condition.new("Truth is the truth", lambda{true == true})], am).class.should == Array
  end
  
  it "should fail on bad validation" do
    am = AnalysisMetadata.gen
    begin
      AnalysisMetadata.validates([Struct::Condition.new("Truth is the !truth", lambda{true == false})], am)
    rescue Exception
      1.should == 1
    end
    
  end
  
  it "should properly boot_out" do
    am = AnalysisMetadata.gen
    $instance = Instance.new
    $instance.metadata = am
    BasicHistogram.boot_out.class.should == AnalysisMetadata
  end
  
  it "should not boot_out when analysis_metadata isn't found" do
    BasicHistogram.boot_out(Curation.gen).class.should == AnalysisMetadata
  end
  
  it "should fail on verifying uniqueness" do
    am = AnalysisMetadata.gen
    am.set_variables!
    am2 = am.dup
    am2.id = nil
    am2.set_variables!
    am2.verify_uniqueness
  end
  
end