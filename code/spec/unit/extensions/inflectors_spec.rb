require 'spec_helper'
describe DataMapper::Inflector do
  it "should inflect entity properly" do
    DataMapper::Inflector.plural("entity").should == "entities"
  end
end