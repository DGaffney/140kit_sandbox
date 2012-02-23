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
  
  it "should generalized_time_factor properly" do
    times = {1 => 1, 3599 => 60, 86399 => 3600, 604799 => 86400, 11535999 => 604800, 11536001 => 2419200}
    times.each_pair do |k,v|
      k.generalized_time_factor.should == v
    end
  end
end