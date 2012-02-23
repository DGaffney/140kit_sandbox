describe Time do
  it "should ntp properly" do
    Time.ntp.class.should == Time
  end
  
  it "should gmt properly" do
    time = Time.now
    time.gmt.class.should == Time
  end
end