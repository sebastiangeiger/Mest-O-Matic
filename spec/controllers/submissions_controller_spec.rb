require 'spec_helper'

describe SubmissionsController do
  before(:each) do
    @project = Project.new(:title => "Project from database")
    @project.stubs(:id).returns(10)
    Project.stubs(:find).with(10).returns @project
    @deliverable = Deliverable.new
    @deliverable.stubs(:id).returns(11)
    @deliverable.stubs(:project).returns @project
    @project.stubs(:deliverables).returns [@deliverables]
    Deliverable.stubs(:find).with(11).returns @deliverable
    @current_user = User.new
    @current_user.stubs(:id).returns 53
    @valid_submission = Submission.new
    @valid_submission.stubs(:valid?).returns true
    
  end
  
  describe "(Authentication)" do
    describe "responding to GET new" do
      it "should grant access to a logged in user" do
        controller.expects(:signed_in?).returns true
        get :new, :deliverable_id => 11, :project_id => 10 
        response.should render_template("submissions/new")
      end
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false
        get :new, :deliverable_id => 11, :project_id => 10 
        response.should redirect_to("/sessions/new")
      end
    end
    describe "responding to POST create" do
      it "should grant access to a logged in user" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @current_user
        post :create, :deliverable_id => 11, :project_id => 10 
        response.should_not redirect_to("/sessions/new")
      end
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false
        post :create, :deliverable_id => 11, :project_id => 10 
        response.should redirect_to("/sessions/new")
      end
    end
  end
  
  describe "(Functional)" do
    before(:each) do
      controller.stubs(:signed_in?).returns true
      controller.stubs(:current_user).returns @current_user
    end
    describe "responding to GET new" do
      it "should assign a new submission object to the submission variable" do
        Submission.expects(:new).returns @valid_submission
        get :new, :project_id => 10, :deliverable_id => 11
        assigns[:submission].should == @valid_submission 
      end
      it "should load and assign the deliverable object" do
        Deliverable.expects(:find).with(11).returns @deliverable
        get :new, :project_id => 10, :deliverable_id => 11
        assigns[:deliverable].should == @deliverable
      end
    end
    describe "responding to POST create" do
      it "should load and assign the deliverable object" do
        Deliverable.expects(:find).with(11).returns @deliverable
        post :create, :project_id => 10, :deliverable_id => 11
        assigns[:deliverable].should == @deliverable
      end
      it "should create a new submission object according to the params" do
        @zipFile = File.new(Rails.root + 'spec/fixtures/files/project_3.zip')
        post :create, :project_id => 10, :deliverable_id => 11, :submission => {:archive => @zipFile} 
        assigns[:submission].archive.original_filename.should == "project_3.zip"
      end
      it "should redirect to the deliverables project path if save was successful" do
        Submission.expects(:new).returns @valid_submission
        post :create, :project_id => 10, :deliverable_id => 11
        response.should redirect_to("/projects/10")  
      end
      it "should add the created submission to the solution's submissions" do
        solution = Solution.new
        Solution.expects(:find_or_create).returns solution
        Submission.expects(:new).returns @valid_submission
        post :create, :project_id => 10, :deliverable_id => 11
        assigns[:solution].should == solution
        assigns[:submission].should == @valid_submission
        assigns[:solution].submissions.should include(assigns[:submission])
      end
      it "should rerender the new template if the save was unsuccessful" do
        invalid_submission = Submission.new
        invalid_submission.stubs(:valid?).returns false
        Submission.expects(:new).returns invalid_submission
        post :create, :project_id => 10, :deliverable_id => 11
        response.should render_template("submissions/new")
      end
    end
  end 
end
