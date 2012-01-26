require 'spec_helper'

describe String do
  it "should underscore properly" do
    "AnalysisMetadata".underscore.should == "analysis_metadata"
  end
  it "should pluralize properly" do
    "AnalysisMetadata".pluralize.should == "analysis_metadatas"
  end
  it "should sanitize_for_streaming properly" do
    "#hashtag '\"".sanitize_for_streaming.should == "%23hashtag%20"
  end
  it "should classify properly" do
    "analysis_metadatas".classify.should == "AnalysisMetadata"
  end
  it "should classify properly" do
    "String".constantize.should == String
  end
  it "should to_class properly" do
    "string".to_class.should == String
  end
  it "should super_strip hashtags properly" do
    "#blah".super_strip.should == "#blah"
  end
  it "should super_strip mentions properly" do
    "@blah".super_strip.should == "@blah"
  end
  it "should super_strip urls properly" do
    "http://google.com".super_strip.should == "http://google.com"
  end
  it "should super_strip normal words properly" do
    "`=>!'+]$(\"[{<)*%};,|~".super_strip.should == ""
  end
  it "should super_split hashtags properly" do
    "#blah".super_split(" ").should == ["#blah"]
  end
  it "should super_split mentions properly" do
    "@blah".super_split(" ").should == ["@blah"]
  end
  it "should super_split urls properly" do
    "http://google.com".super_split(" ").should == ["http://google.com"]
  end
  it "should super_split normal words properly" do
    "`=>!'+]$(\"[{<)*%};,|~".super_split(" ").should == []
  end
end