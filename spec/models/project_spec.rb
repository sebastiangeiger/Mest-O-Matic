require_relative '../spec_helper.rb'

describe Project do
  it "should create a project with a title, a semester and a start date" do
    Project.create(:title => "Test", :semester => Semester.new, :start => Date.new).should be_valid
  end

  it "should not create a project without a semester" do
    Project.create(:title => "Test", :start => Date.new).should_not be_valid
  end

  it "should not create a project without a title" do
    Project.create(:semester => Semester.new, :start => Date.new).should_not be_valid
  end
  
  it "should not create a project without a start date" do
    Project.create(:title => "Test", :semester => Semester.new).should_not be_valid
  end
end