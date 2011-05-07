require_relative '../spec_helper.rb'

describe ClassOf do
  it "should not be valid without any parameters" do
    ClassOf.create().should_not be_valid
  end
  
  it "should be valid with a year" do
    ClassOf.create(:year => 2001).should be_valid
  end

  it "should be valid with a string that is a year" do
    ClassOf.create(:year => "2001").should be_valid
  end
  
  it "should not be valid with a string that is not a year" do
    ClassOf.create(:year => "SomeString").should_not be_valid
  end

  it "should not be creating two objects with the same year" do
    ClassOf.create(:year => 2001)
    ClassOf.create(:year => 2001).should_not be_valid
  end
  
end