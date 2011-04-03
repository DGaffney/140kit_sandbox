describe AnalyticalOffering do
  it "should return a hash of language extensions" do
    AnalyticalOffering.language_extensions("ruby").should == ".rb"
  end
  
  it "should generate proper variables" do
    AnalyticalOffering.all.each do |ao|
      ao.variables.class.should == Array
    end
  end
end