require_relative '../spec_helper.rb'

describe Semester do
  before(:each) do
    @class_of = ClassOf.new
    @class_of.stubs(:id).returns(1)
    @class_of_2 = ClassOf.new
    @class_of.stubs(:id).returns(2)
  end

  it "should create a semester with a class_of and a nr" do
    Semester.create(:class_of => @class_of, :nr => 1).should be_valid
  end

  it "should not create a semester with only a class_of" do
    Semester.create(:class_of => @class_of).should_not be_valid
  end

  it "should not create a semester with only a nr" do
    Semester.create(:nr => 1).should_not be_valid
  end

  it "should not create a semester without arguments" do
    Semester.create().should_not be_valid
  end

  it "should create two semesters with same class of but different nrs" do
    Semester.create(:class_of => @class_of, :nr => 1).should be_valid
    Semester.create(:class_of => @class_of, :nr => 2).should be_valid    
  end

  it "should create two semesters with same nrs of but for different clases" do
    Semester.create(:class_of => @class_of, :nr => 1).should be_valid
    Semester.create(:class_of => @class_of_2, :nr => 1).should be_valid    
  end

  it "should not create two semesters with same class and same nrs" do
    Semester.create(:class_of => @class_of, :nr => 1).should be_valid
    Semester.create(:class_of => @class_of, :nr => 1).should_not be_valid    
  end
end