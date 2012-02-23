describe AnalyticalOfferingVariable do
  before :all do
    researcher = Researcher.gen
    researcher.save!
    curation = Curation.gen
    curation.save!
    dataset = Dataset.gen
    dataset.save!
    dataset.curations << curation
    analytical_offering = AnalyticalOffering.gen
    analytical_offering.save!
    analysis_metadata = AnalysisMetadata.gen
    analysis_metadata.save!
    analytical_offering_variable_descriptor = AnalyticalOfferingVariableDescriptor.gen
    analytical_offering_variable_descriptor.save!
    analytical_offering_variable = AnalyticalOfferingVariable.gen
    analytical_offering_variable.save!
  end
  it "should return a function" do
    aov = AnalyticalOfferingVariable.first
    aov.function.class.should == String
  end
  it "should return a name" do
    aov = AnalyticalOfferingVariable.first
    aov.name.class.should == String
  end
  it "should return a kind" do
    aov = AnalyticalOfferingVariable.first
    aov.kind.class.should == String
  end
  it "should return a position" do
    aov = AnalyticalOfferingVariable.first
    aov.position.class.should == Fixnum
  end
end