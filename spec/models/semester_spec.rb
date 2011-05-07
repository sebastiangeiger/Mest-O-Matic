require_relative '../spec_helper.rb'

describe Semester do
  it "should create a semester with a class_of and a nr" do
    Semester.create(:class_of => ClassOf.new, :nr => 1).should be_valid
  end

  it "should not create a semester with only a class_of" do
    Semester.create(:class_of => ClassOf.new).should_not be_valid
  end

  it "should not create a semester with only a nr" do
    Semester.create(:nr => 1).should_not be_valid
  end

  it "should not create a semester without arguments" do
    Semester.create().should_not be_valid
  end

  it "should create two semesters with same class of but different nrs" do
    class_of = ClassOf.new()
    Semester.create(:class_of => class_of, :nr => 1).should be_valid
    Semester.create(:class_of => class_of, :nr => 2).should be_valid    
  end

  it "should not create two semesters with same class and same nrs" do
    class_of = ClassOf.new()
    Semester.create(:class_of => class_of, :nr => 1).should be_valid
    Semester.create(:class_of => class_of, :nr => 1).should_not be_valid    
  end
end