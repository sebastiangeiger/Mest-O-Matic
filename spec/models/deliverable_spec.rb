require_relative '../spec_helper.rb'

describe Deliverable do
  before(:each) do
    class_of = ClassOf.new
    class_of.stubs(:eits).returns []
    @project = Project.new
    @project.stubs(:id).returns(1)
    @project_2 = Project.new
    @project_2.stubs(:id).returns(2)
    @project.stubs(:class_of).returns class_of
    @project_2.stubs(:class_of).returns class_of
    @author = User.new
  end
  
  it "should create a deliverable with a title, a project, start/end dates and an author" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should be_valid
  end
  
  it "should not create a deliverable without a title" do
    Deliverable.create(:project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should_not be_valid    
  end

  it "should not create a deliverable without a project" do
    Deliverable.create(:title => "Some deliverable", :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should_not be_valid    
  end

  it "should not create a deliverable without a start date" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :end_date => Time.now, :author => @author).should_not be_valid    
  end

  it "should not create a deliverable without a end date" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :author => @author).should_not be_valid    
  end

  it "should not create a deliverable without an author" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now).should_not be_valid    
  end

  it "should create two deliverables with the same title in different projects" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should be_valid
    Deliverable.create(:title => "Some deliverable", :project => @project_2, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should be_valid
  end

  it "should not create two deliverables with the same title in the same project" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should be_valid
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should_not be_valid
  end

  it "should not create two deliverables with the same title in the same project (ignoring case)" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should be_valid
    Deliverable.create(:title => "SOME DELIVERABLE", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should_not be_valid
  end

  it "should create two deliverables with the different titles in the same project" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should be_valid
    Deliverable.create(:title => "SOME other DELIVERABLE", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should be_valid
  end
  
  it "should create a deliverable if the start date is before the end date" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author).should be_valid    
  end

  it "should not create a deliverable if the start date is after the end date" do
    Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now+1.day, :end_date => Time.now, :author => @author).should_not be_valid    
  end
  
  describe "#versions" do
    before(:each) do
      @deliverable = Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author)
      @eit1 = Eit.new
      @eit1.stubs(:id).returns 11
      @eit2 = Eit.new
      @eit2.stubs(:id).returns 12
      @d1 = DateTime.now-1.hour
      @d2 = DateTime.now-30.minutes
      @d3 = DateTime.now-5.minutes
    end

    it "should have one version if there is no solution" do
      @deliverable.stubs(:submissions).returns []
      @deliverable.versions.should == {0 => []}
    end
    it "should have two versions if one solution with one submission exists" do
      solution = Solution.new(:deliverable => @deliverable, :user => @eit1)
      submission = FileSubmission.new(:solution => solution)
      submission.stubs(:created_at).returns @d1
      @deliverable.stubs(:submissions).returns [submission]
      @deliverable.versions.should == {0 => [], 1 => [submission]}
    end
    it "should have three versions if two submissions by one user exist, one submission is replaced by the newer one" do
      solution = Solution.new(:deliverable => @deliverable, :user => @eit1)
      s1 = FileSubmission.new(:solution => solution)
      s1.stubs(:created_at).returns @d1
      s2 = FileSubmission.new(:solution => solution)
      s2.stubs(:created_at).returns @d2
      @deliverable.stubs(:submissions).returns [s1,s2]
      @deliverable.versions.should == {0 => [], 1 => [s1], 2 => [s2]}
    end
    it "should have three versions if two submissions on two solutions exist" do
      sol1 = Solution.new(:deliverable => @deliverable, :user => @eit1)
      sol2 = Solution.new(:deliverable => @deliverable, :user => @eit2)
      s1 = FileSubmission.new(:solution => sol1)
      s1.stubs(:created_at).returns @d1
      s2 = FileSubmission.new(:solution => sol2)
      s2.stubs(:created_at).returns @d2
      @deliverable.stubs(:submissions).returns [s1,s2]
      @deliverable.versions.should == {0 => [], 1 => [s1], 2 => [s1,s2]}
    end
    it "should have three versions if three submissions by one user exist, one submission is replaced by the newer one" do
      solution = Solution.new(:deliverable => @deliverable, :user => @eit1)
      s1 = FileSubmission.new(:solution => solution)
      s1.stubs(:created_at).returns @d1
      s2 = FileSubmission.new(:solution => solution)
      s2.stubs(:created_at).returns @d2
      s3 = FileSubmission.new(:solution => solution)
      s3.stubs(:created_at).returns @d3
      @deliverable.stubs(:submissions).returns [s1,s2,s3]
      @deliverable.versions.should == {0 => [], 1 => [s1], 2 => [s2], 3 => [s3]}
    end
    it "should have one version if two solutions, one with one and one with two submission exists" do
      sol1 = Solution.new(:deliverable => @deliverable, :user => @eit1)
      sol2 = Solution.new(:deliverable => @deliverable, :user => @eit2)
      s1 = FileSubmission.new(:solution => sol1)
      s1.stubs(:created_at).returns @d1
      s2 = FileSubmission.new(:solution => sol2)
      s2.stubs(:created_at).returns @d2
      s3 = FileSubmission.new(:solution => sol1)
      s3.stubs(:created_at).returns @d3
      @deliverable.stubs(:submissions).returns [s1,s3,s2]
      @deliverable.versions.should == {0 => [], 1 => [s1], 2 => [s1,s2], 3 => [s2,s3]}
    end
  end
  describe "#download_version" do
    
  end
  
  describe "#remove_root_path" do
    it "should return the path when the root path is nil" do
      Deliverable.remove_root_path("a/b.txt", nil).should == "a/b.txt"
    end
    it "should return the path when the root path is empty" do
      Deliverable.remove_root_path("a/b.txt", "").should == "a/b.txt"
    end
    it "should return b.txt when given 'a/b.txt' and a root 'a'" do
      Deliverable.remove_root_path("a/b.txt", "a").should == "b.txt"
    end
    it "should return 'b/c.txt' when given 'a/b/c.txt and a root 'a/b'" do
      Deliverable.remove_root_path("a/b/c.txt", "a").should == "b/c.txt"
    end
    it "should return 'c/d' when given 'a/b/c/d' and a root 'a/b'" do
      Deliverable.remove_root_path("a/b/c/d", "a/b").should == "c/d"
    end
  end

  describe "#eits_submitted" do
    before(:each) do
      @sol = Solution.new
      @sol.stubs(:user).returns @eit1
      @del = Deliverable.new
      @del.stubs(:solutions).returns [@sol]

    end
    it "should return an empty list if there is an Eit that has only the inital submission" do
      sub = Submission.new
      @sol.stubs(:submissions).returns [sub]
      @del.eits_submitted.should == [] 
    end
    it "should return a list with the Eit if there is an Eit that has only the inital submission" do
      sub = FileSubmission.new
      @sol.stubs(:submissions).returns [sub]
      @del.eits_submitted.should == [@eit1] 
    end
  end
end
