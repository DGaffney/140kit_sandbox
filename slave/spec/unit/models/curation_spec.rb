require 'spec_helper'

describe Curation do
  it "should not be created without a researcher" do
        debugger
    c = Curation.gen
    c.researcher_id = nil
    c.save!
  end
end
