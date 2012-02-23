describe Analysis do
  it "should convert conditions to mysql with simple keys and simple values" do
    Analysis.conditions_to_mysql_query({:curation_id => 1}).class.should == String
  end

  it "should convert conditions to mysql with simple keys and complex values" do
    Analysis.conditions_to_mysql_query({:curation_id => [1,2,3,4]}).class.should == String
  end

  it "should convert conditions to mysql with complex keys and simple values" do
    Analysis.conditions_to_mysql_query({[:curation_id, :id] => 1}).class.should == String
  end

  it "should convert conditions to mysql with complex keys and complex values" do
    Analysis.conditions_to_mysql_query({[:curation_id, :id] => [1,2,3,4]}).class.should == String
  end

  it "should generate a curation conditional" do
    researcher = Researcher.gen
    curation = Curation.gen
    Analysis.curation_conditional(curation).class.should == Hash
  end

  it "should generate a time_conditional for hour" do
    Analysis.time_conditional(:created_at, "2010-01-01 00", "hour").class.should == Hash
  end

  it "should generate a time_conditional for date" do
    Analysis.time_conditional(:created_at, "2010-01-01", "date").class.should == Hash
  end

  it "should generate a time_conditional for month" do
    Analysis.time_conditional(:created_at, "2010-01", "month").class.should == Hash
  end

  it "should generate a time_conditional for year" do
    Analysis.time_conditional(:created_at, "2010", "year").class.should == Hash
  end
   
end