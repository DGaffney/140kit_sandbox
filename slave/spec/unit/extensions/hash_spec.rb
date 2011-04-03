require 'spec_helper'

describe Hash do 
  it "should flatify properly" do
    {"ball" => {"one" => 2, "two" => 2}}.flatify.should == {"ball-two"=>2, "ball-one"=>2}
  end
  
  it "should return highest pair" do
     {"one" => 1, "two" => 2}.highest.should == {"two" => 2}
  end
  
  it "should return lowest pair" do
     {"one" => 1, "two" => 2}.lowest.should == {"one" => 1}
  end
    
end