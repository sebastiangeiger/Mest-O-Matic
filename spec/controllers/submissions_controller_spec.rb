require 'spec_helper'

describe SubmissionsController do
  before(:each) do
    class_a = ClassOf.new
    class_b = ClassOf.new
    @project = Project.new(:title => "Project from database")
    @project.stubs(:id).returns(10)
    @project.stubs(:class_of).returns class_a
    Project.stubs(:find).with(10).returns @project
    @deliverable = Deliverable.new
    @deliverable.stubs(:id).returns(11)
    @deliverable.stubs(:project).returns @project
    @project.stubs(:deliverables).returns [@deliverables]
    Deliverable.stubs(:find).with(11).returns @deliverable
    @user = User.new
    @user.stubs(:id).returns 53
    @eit = Eit.new
    @eit.stubs(:id).returns 55
    @eit.stubs(:class_of).returns class_a
    @foreign_eit = Eit.new
    @foreign_eit.stubs(:id).returns 57
    @foreign_eit.stubs(:class_of).returns class_b
    @staff = Staff.new
    @staff.stubs(:id).returns 59
    @valid_submission = Submission.new
    @valid_submission.stubs(:valid?).returns true
    @zipFile = File.new(Rails.root + 'spec/fixtures/files/zip_file.zip')    
    request.env["HTTP_REFERER"] = "navigate back"
  end
  
  describe "(Authentication)" do
    describe "responding to GET new" do
      it "should not grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @staff
        get :new, :deliverable_id => 11, :project_id => 10 
        response.should redirect_to("/projects/10")
        flash[:error].should_not be_empty
      end
      it "should not grant access to an eit that cannot work on this project" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @foreign_eit
        get :new, :deliverable_id => 11, :project_id => 10 
        response.should redirect_to("/projects")
        flash[:error].should_not be_empty
      end
      it "should grant access to an Eit that is in the same class as the project" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @eit
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
      it "should not grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @staff
        post :create, :deliverable_id => 11, :project_id => 10 
        response.should redirect_to("/projects/10")
        flash[:error].should_not be_empty
      end
      it "should not grant access to an eit that cannot work on this project" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @foreign_eit
        post :create, :deliverable_id => 11, :project_id => 10 
        response.should redirect_to("/projects")
        flash[:error].should_not be_empty
      end
      it "should grant access to an Eit that is in the same class as the project" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @eit
        FileSubmission.any_instance.stubs(:valid?).returns true
        post :create, :deliverable_id => 11, :project_id => 10 
        flash[:notice].should_not be_empty
        response.should redirect_to("/projects/10")
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
      controller.stubs(:current_user).returns @eit
    end
    describe "responding to GET new" do
      it "should assign a new submission object to the submission variable" do
        FileSubmission.expects(:new).returns @valid_submission
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
        post :create, :project_id => 10, :deliverable_id => 11, :file_submission => {:archive => @zipFile} 
        assigns[:submission].archive.original_filename.should == "zip_file.zip"
      end
      it "should redirect to the deliverables project path if save was successful" do
        FileSubmission.expects(:new).returns @valid_submission
        post :create, :project_id => 10, :deliverable_id => 11
        response.should redirect_to("/projects/10")  
      end
      it "should add the created submission to the solution's submissions" do
        solution = Solution.new
        Solution.expects(:find_or_create).returns solution
        FileSubmission.expects(:new).returns @valid_submission
        post :create, :project_id => 10, :deliverable_id => 11
        assigns[:solution].should == solution
        assigns[:submission].should == @valid_submission
        assigns[:solution].submissions.should include(assigns[:submission])
      end
      it "should rerender the new template if the save was unsuccessful" do
        invalid_submission = Submission.new
        invalid_submission.stubs(:valid?).returns false
        FileSubmission.expects(:new).returns invalid_submission
        post :create, :project_id => 10, :deliverable_id => 11
        response.should render_template("submissions/new")
      end
    end
  end 
end
