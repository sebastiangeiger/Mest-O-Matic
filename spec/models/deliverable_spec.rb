require_relative '../spec_helper.rb'

describe Deliverable do
  before(:each) do
    @class_of = ClassOf.new
    @class_of.stubs(:eits).returns []
    @project = Project.new
    @project.stubs(:id).returns(1)
    @project_2 = Project.new
    @project_2.stubs(:id).returns(2)
    @project.stubs(:class_of).returns @class_of
    @project_2.stubs(:class_of).returns @class_of
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
  
  it "should create one solution if there is one user, the solution should have one submission" do
    eit = Eit.new
    eit.stubs(:id).returns 42
    @class_of.stubs(:eits).returns [eit]
    d = Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author)
    d.should be_valid
    d.solutions.size.should == 1
    d.solutions.first.submissions.size.should == 1
  end

  it "should create two solutions if there are two users, both solutions should have one submission" do
    eit = Eit.new
    eit.stubs(:id).returns 42
    eit2 = Eit.new
    eit2.stubs(:id).returns 43
    @class_of.stubs(:eits).returns [eit, eit2]
    d = Deliverable.create(:title => "Some deliverable", :project => @project, :start_date => Time.now-1.day, :end_date => Time.now, :author => @author)
    d.should be_valid
    d.solutions.size.should == 2
    d.solutions[0].submissions.size.should == 1
    d.solutions[1].submissions.size.should == 1
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
      @zipFile = File.new(Rails.root + 'spec/fixtures/files/zip_file.zip')
    end

    it "should have one version if there is no file submitted" do
      solution = Solution.create(:deliverable => @deliverable, :user => @eit1)
      s = Submission.create(:solution => solution)
      @deliverable.stubs(:solutions).returns [solution]
      @deliverable.versions.should == {0 => [s]}
    end
    it "should have two versions if there is one file submitted exists" do
      solution = Solution.create(:deliverable => @deliverable, :user => @eit1)
      s =      Submission.create(:solution => solution)
      fs = FileSubmission.create(:solution => solution, :archive => @zipFile)
      @deliverable.stubs(:solutions).returns [solution]
      @deliverable.versions.should == {0 => [s], 1 => [fs]}
    end
    it "should have three versions if two submissions by one user exist, one submission is replaced by the createer one" do
      solution = Solution.create(:deliverable => @deliverable, :user => @eit1)
      s   =     Submission.create(:solution => solution)
      fs1 = FileSubmission.create(:solution => solution, :archive => @zipFile)
      fs2 = FileSubmission.create(:solution => solution, :archive => @zipFile)
      @deliverable.stubs(:solutions).returns [solution]
      @deliverable.versions.should == {0 => [s], 1 => [fs1], 2 => [fs2]}
    end
    it "should have three versions if two submissions on two solutions exist" do
      sol1 = Solution.create(:deliverable => @deliverable, :user => @eit1)
      sol2 = Solution.create(:deliverable => @deliverable, :user => @eit2)
      s1  =     Submission.create(:solution => sol1)
      s2  =     Submission.create(:solution => sol2)
      fs1 = FileSubmission.create(:solution => sol1, :archive => @zipFile)
      fs2 = FileSubmission.create(:solution => sol2, :archive => @zipFile)
      @deliverable.stubs(:solutions).returns [sol1,sol2]
      @deliverable.stubs(:submissions).returns [s1,s2,fs1,fs2]
      @deliverable.versions.should == {0 => [s1,s2], 1 => [s2,fs1], 2 => [fs1,fs2]}
    end
    it "should have three versions if three submissions by one user exist, one submission is replaced by the createer one" do
      solution = Solution.create(:deliverable => @deliverable, :user => @eit1)
      s   =     Submission.create(:solution => solution)
      fs1 = FileSubmission.create(:solution => solution, :archive => @zipFile)
      fs2 = FileSubmission.create(:solution => solution, :archive => @zipFile)
      fs3 = FileSubmission.create(:solution => solution, :archive => @zipFile)
      @deliverable.stubs(:submissions).returns [s,fs1,fs2,fs3]
      @deliverable.versions.should == {0 => [s], 1 => [fs1], 2 => [fs2], 3 => [fs3]}
    end
    it "should have one version if two solutions, one with one and one with two submission exists" do
      sol1 = Solution.create(:deliverable => @deliverable, :user => @eit1)
      sol2 = Solution.create(:deliverable => @deliverable, :user => @eit2)
      s1  =     Submission.create(:solution => sol1)
      s2  =     Submission.create(:solution => sol2)
      fs1 = FileSubmission.create(:solution => sol1, :archive => @zipFile)
      fs2 = FileSubmission.create(:solution => sol2, :archive => @zipFile)
      fs3 = FileSubmission.create(:solution => sol1, :archive => @zipFile)
      @deliverable.stubs(:submissions).returns [s1,s2,fs1,fs3,fs2]
      @deliverable.versions.should == {0 => [s1,s2], 1 => [s2,fs1], 2 => [fs1,fs2], 3 => [fs2,fs3]}
    end
  end
  describe "#download_version" do
    
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
  
  describe "#reviews_missing?" do
    before(:each) do
      @del = Deliverable.new
      @rev1 = Review.new
      @rev2 = Review.new
      @sub1 = Submission.new
      @sub2 = Submission.new
      @sub1.stubs(:review).returns @rev1
      @sub2.stubs(:review).returns @rev2
      @del.stubs(:latest_version).returns [@sub1, @sub2]
    end
    it "should return true if one of the revisions is nil" do
      @sub1.stubs(:review).returns nil
      @sub2.stubs(:review).returns nil
      @del.reviews_missing?.should == true
    end
    it "should return true if both revision are nil" do
      @sub1.stubs(:review).returns nil
      @del.reviews_missing?.should == true
    end
    it "should return false if both revision are there" do 
      @del.reviews_missing?.should == false
    end
  end

  describe "#closed?" do
    before(:each) do
      @del = Deliverable.new
      @del.start_date = Time.now - 7.days
      @rev1 = Review.new
      @rev2 = Review.new
      @rev1.stubs(:updated_at).returns (Time.now - 1.month - 1.day)
      @rev2.stubs(:updated_at).returns (Time.now - 1.month - 1.day - 1.minutes)
      @sub1 = Submission.new
      @sub2 = Submission.new
      @sub1.stubs(:review).returns @rev1
      @sub2.stubs(:review).returns @rev2
      @del.stubs(:latest_version).returns [@sub1, @sub2]
    end

    it "should return false if there are two submissions but only one has a review" do
      @sub2.stubs(:review).returns nil
      @del.should_not be_closed
    end
    it "should return false if all submissions have a review but the last time a review has been updated is only two weeks ago" do
      @rev1.stubs(:updated_at).returns (Time.now - 2.weeks)
      @del.should_not be_closed
    end
    it "should return true if there all submissions have review and they both have been updated one month and one day ago"# do
      #@del.should be_closed
    #end
  end

  describe "#process_corrections_archive" do
    before(:each) do
      @del = Deliverable.new
      MyZip.expects(:unzip_file).with("/path/to/zipfile", anything).returns("/path/to/unzipped")
      Dir.expects(:entries).with("/path/to/unzipped").returns(%w[. .. unzipped_archive])
      File.expects(:directory?).with("/path/to/unzipped/unzipped_archive").returns true
      @e1 = Eit.new
      @e1.email = "eit1@meltwater.org"
      @e2 = Eit.new
      @e2.email = "eit2@meltwater.org"
      @del.stubs(:safe_title).returns "deliverabletitle"
      @project = Project.new
      @project.stubs(:safe_title).returns "projecttitle"
      @del.stubs(:project).returns @project
      @sol1 = Solution.new
      @sub1 = Submission.new
      @sol1.stubs(:submissions).returns [Submission.new, @sub1]
      @rev1 = Review.new
      @rev1.stubs(:submission).returns @sub1
      @sub1.stubs(:review).returns @rev1
      @sub1.stubs(:version).returns 1
      @sol2 = Solution.new
      @sub2 = Submission.new
      @sol2.stubs(:submissions).returns [Submission.new, @sub2]
      @rev2 = Review.new
      @rev2.stubs(:submission).returns @sub2
      @sub2.stubs(:review).returns @rev2
      @sub2.stubs(:version).returns 1
    end

    it "should return with an unzipped archive with two eits and two eits for the deliverable returns true" do
      Dir.expects(:entries).with("/path/to/unzipped/unzipped_archive").returns %w[. .. eit1_1 eit2_1]
      @del.expects(:eits_submitted).at_least_once.returns [@e1, @e2]
      Solution.stubs(:find_or_create).with(:user => @e1, :deliverable => @del).returns @sol1 
      Solution.stubs(:find_or_create).with(:user => @e2, :deliverable => @del).returns @sol2 
      MyZip.expects(:zip_file).with("/path/to/unzipped/unzipped_archive/eit1_1", anything)
      MyZip.expects(:zip_file).with("/path/to/unzipped/unzipped_archive/eit2_1", anything)
      @del.process_corrections_archive("/path/to/zipfile").should == true 
    end
    it "should return with an unzipped archive with one eits and two eits for the deliverable returns false" do
      Dir.expects(:entries).with("/path/to/unzipped/unzipped_archive").returns %w[. .. eit1_1]
      @del.expects(:eits_submitted).at_least_once.returns [@e1, @e2]
      @del.process_corrections_archive("/path/to/zipfile").should == false 
    end
    it "should return with an unzipped archive with three eits and two eits for the deliverable returns ignores the superflous user and returns true" do
      Dir.expects(:entries).with("/path/to/unzipped/unzipped_archive").returns %w[. .. eit1_1 eit2_1 eit3_1]
      @del.expects(:eits_submitted).at_least_once.returns [@e1, @e2]
      Solution.stubs(:find_or_create).with(:user => @e1, :deliverable => @del).returns @sol1 
      Solution.stubs(:find_or_create).with(:user => @e2, :deliverable => @del).returns @sol2 
      MyZip.expects(:zip_file).with("/path/to/unzipped/unzipped_archive/eit1_1", anything)
      MyZip.expects(:zip_file).with("/path/to/unzipped/unzipped_archive/eit2_1", anything)
      @del.process_corrections_archive("/path/to/zipfile").should == true 
    end
  end
end
