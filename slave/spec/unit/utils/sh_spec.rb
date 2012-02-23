describe Sh do
  
  it "should hostname properly" do
    `hostname`.chomp.should == Sh::hostname
  end
  
  it "should sh properly" do
    `pwd`.chomp.should == Sh::sh("pwd")
  end
  
  it "should clean_gets properly" do
    STDIN.expects(:gets).returns("hi\n")
    answer = Sh::clean_gets
    answer.should == "hi"
  end
  
  it "should clean_gets_yes_no yes answer properly" do
    STDIN.stubs(:gets).returns("y\n")
    answer = Sh::clean_gets_yes_no
    answer.should == true
  end
  
  it "should clean_gets_yes_no no answer properly" do
    STDIN.stubs(:gets).returns("n\n")
    answer = Sh::clean_gets_yes_no
    answer.should == false
  end

  it "should clean_gets_yes_no wrong answer properly" do
    STDIN.stubs(:gets).returns("x\n")
    answer = Sh::clean_gets_yes_no
    answer.should == nil
  end
  
  it "should mkdir properly" do
    Sh::mkdir("path/to/location")
    response = Sh::sh("ls path/to/location")
    response.should == ""
    Sh::sh("rm -r path")
  end
end
