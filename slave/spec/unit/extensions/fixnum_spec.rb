require 'spec_helper'
describe Fixnum do 
  it "should days properly" do
    1.days.should == 86400
  end
  it "should day properly" do
    1.day.should == 86400
  end
  it "should weeks properly" do
    1.weeks.should == 604800    
  end
  it "should week properly" do
    1.week.should == 604800
  end
end