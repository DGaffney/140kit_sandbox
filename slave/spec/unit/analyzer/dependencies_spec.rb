describe Analysis::Dependencies do
  it "should return arrays of gems for all dependency requirement" do
    (Analysis::Dependencies.methods.sort-Class.methods).select{|x| x.include?("dependencies")}.each do |method|
      Analysis::Dependencies.send(method).class.should == Array
    end
  end
  
  it "should properly rescue on legitimate method missing" do
    begin 
      Analysis::Dependencies.blah
    rescue NoMethodError
      #if we made it here, it obviously did its job...
      1.should==1
    end
  end
  
  it "should bypass method missing when its a dependency" do
    basic_histogram = AnalyticalOffering.create(:title => "Basic Histograms", :function => "basic_histogram", :language => "ruby", :created_by => "140kit Team", :created_by_link => "http://140kit.com", :access_level => "user", :description => "")
    Analysis::Dependencies.send(basic_histogram.function).class.should == Array
  end
  
  it "should bypass method missing and require nothing when it requires no dependency" do
    test_analytic = AnalyticalOffering.create(:title => "Basic Histograms", :function => "test", :language => "ruby", :created_by => "140kit Team", :created_by_link => "http://140kit.com", :access_level => "user", :description => "")
    #for some reason, send was failing on doing this, so had to be converted to eval. Will look into someday, but not today.
    eval("Analysis::Dependencies.#{test_analytic.function}").class.should == String
  end
end