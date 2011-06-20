require 'spec_helper'
describe Array do
  it "should properly sum an array" do
    [1,2,3,4].sum.should == 10
  end
  
  it "should convert to_i" do
    ["1", "2", "3", "4"].to_i.should == [1, 2, 3, 4]
  end

  it "should convert to_f" do
    ["1", "2", "3", "4"].to_f.should == [1.0, 2.0, 3.0, 4.0]
  end

  it "should generate frequencies" do
    [1,1,2,2,3,3,4,4].frequencies.should == {"1" => 2, "2" => 2, "3" => 2, "4" => 2}
  end
  
  it "should chunk properly" do
    [1,2,3,4].chunk.should == [[1,2],[3,4]]
  end
  
  it "should repack" do
    iterator = 0
    [1,2,3,4].repack do |arr|
      case iterator.to_s
      when "0"
        arr.should == [1]
      when "1"
        arr.should == [1,2]
      when "2"
        arr.should == [1,2,3]
      when "3"
        arr.should == [1,2,3,4]
      end
      iterator+=1
    end
  end
  
  it "should calculate centroid properly" do
    [0,1,1,2].centroid.should == [1,1]
  end
  
  it "should produce all_combinations" do
    [0,1,1,2].all_combinations.should == [[0, 1, 1, 2], [0, 1, 1], [0, 1, 2], [1, 1, 2], [0, 1], [0, 2], [1, 1], [1, 2], [0], [1], [2]]
  end
end
