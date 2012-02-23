describe Instance do
  before :all do 
    instance = Instance.new
    instance.save
  end
  
  it "should check in" do
    instance = Instance.last
    instance.check_in.class.should == Thread
  end
  
  it "should return a whitelisting status" do
    instance = Instance.last
    result = instance.whitelisted?.class
    [TrueClass,FalseClass].include?(result).should == true
  end
  
  it "should know if it's been killed" do
    instance = Instance.last
    result = instance.killed?.class
    [TrueClass,FalseClass].include?(result).should == true
  end
  
  it "should be able to kill all of its own locks" do
    instance = Instance.last
    result = instance.unlock_all.class
    [TrueClass,FalseClass].include?(result).should == true
  end
end