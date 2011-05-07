require_relative '../spec_helper.rb'

describe Subject do
  it "should create a subject with a title" do
    Subject.create(:title => "Business").should be_valid
  end
  
  it "should not create a subject without a title" do
    Subject.create().should_not be_valid
  end
  
  it "should not create a subject with a blank title" do
    Subject.create(:title => "").should_not be_valid
  end

  it "should not create a subject with a title full of spaces" do
    Subject.create(:title => "   ").should_not be_valid
  end

  it "should create two subjects with the same title" do
    Subject.create(:title => "Business").should be_valid
    Subject.create(:title => "Business").should_not be_valid
  end

  it "should create two subjects with the same title (case insensitive)" do
    Subject.create(:title => "Business").should be_valid
    Subject.create(:title => "BUSINESS").should_not be_valid
  end
end
