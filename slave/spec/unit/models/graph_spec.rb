describe Graph do 
  it "should store a proper folder name for time_slice" do
    g = Graph.gen
    g.time_slice = Time.now
    g.year = nil
    g.month = nil
    g.date = nil
    g.hour = nil
    g.save
    g.folder_name.should == g.time_slice.strftime("%Y/%m/%d/%H/%M/%S")
  end
  it "should store a proper folder name for year/month/date/hour" do
    g = Graph.gen
    g.save
    g.folder_name.should == [g.year,g.month,g.date,g.hour].compact.join("/")
  end
  it "should store a proper folder name for year/month/date" do
    g = Graph.gen
    g.hour = nil
    g.save
    g.folder_name.should == [g.year,g.month,g.date,g.hour].compact.join("/")
  end
  it "should store a proper folder name for year/month" do
    g = Graph.gen
    g.date = nil
    g.hour = nil
    g.save
    g.folder_name.should == [g.year,g.month,g.date,g.hour].compact.join("/")
  end
  it "should store a proper folder name for year" do
    g = Graph.gen
    g.month = nil
    g.date = nil
    g.hour = nil
    g.save
    g.folder_name.should == [g.year,g.month,g.date,g.hour].compact.join("/")
  end
  it "should store a proper folder name for time_slice" do
    g = Graph.gen
    g.year = nil
    g.month = nil
    g.date = nil
    g.hour = nil
    g.save
    g.folder_name.should == ""
  end
end