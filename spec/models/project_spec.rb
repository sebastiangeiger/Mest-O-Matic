require_relative '../spec_helper.rb'

describe Project do
  it "should create a project with a title, a semester, a start date and a existing type" do
    p = Project.create(:title => "Test", :semester => Semester.new, :start => Date.new)
    p.type = "Quiz"
    p.should be_valid
  end

  it "should not create a project without a semester" do
    p = Project.create(:title => "Test", :start => Date.new)
    p.type = "Quiz"
    p.should_not be_valid
  end

  it "should not create a project without a title" do
    p = Project.create(:semester => Semester.new, :start => Date.new)
    p.type = "Quiz"
    p.should_not be_valid
  end
  
  it "should not create a project without a start date" do
    p = Project.create(:title => "Test", :semester => Semester.new)
    p.type = "Quiz"
    p.should_not be_valid
  end

  it "should not create a project without a type" do
    p = Project.create(:title => "Test", :semester => Semester.new, :start => Date.new)
    p.should_not be_valid
  end

  it "should not create a project with a title, a semester, a start date and a non-existing type" do
    p = Project.create(:title => "Test", :semester => Semester.new, :start => Date.new)
    p.type = "NoTypeAtAll"
    p.should_not be_valid
  end

  it "should return an empty project list for a user" do
    Project.for_user(User.new).should == []
  end
  it "should return a list with one element if the user is an eit and there are two projects where only one project applies to the eit" do
    eit = Eit.new
    class_of = ClassOf.new
    eit.stubs(:class_of).returns(class_of)
    sem1 = Semester.new
    sem1.stubs(:class_of).returns class_of
    sem2 = Semester.new
    sem2.stubs(:class_of).returns ClassOf.new
    p1 = Project.new
    p1.stubs(:semester).returns sem1
    p2 = Project.new
    p2.stubs(:semester).returns sem2
    Project.stubs(:all).returns [p1,p2]
    Project.for_user(eit).should == [p1]
  end
  it "should return a list with two elements of the user is a staff member" do
    sem1 = Semester.new
    sem1.stubs(:class_of).returns ClassOf.new
    sem2 = Semester.new
    sem2.stubs(:class_of).returns ClassOf.new
    p1 = Project.new
    p1.stubs(:semester).returns sem1
    p2 = Project.new
    p2.stubs(:semester).returns sem2
    Project.stubs(:all).returns [p1,p2]
    Project.for_user(Staff.new).should == [p1,p2]
  end
end
