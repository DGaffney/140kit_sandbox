require 'spec_helper'

describe NilClass do
  it "should register empty as true" do
    nil.empty?.should == true
  end
end
