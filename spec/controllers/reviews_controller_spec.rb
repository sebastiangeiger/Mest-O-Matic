require 'spec_helper'

describe ReviewsController do
  before(:each) do
    @staff = Staff.new
    @staff.stubs(:id).returns(11)
    @deliverable = Deliverable.new
    @deliverable.stubs(:id).returns(11)
    @project = Project.new
    @project.stubs(:id).returns(10)
    @deliverable.stubs(:project).returns(@project)
    Deliverable.stubs(:find).with(11).returns @deliverable
    request.env["HTTP_REFERER"] = "navigate back"
  end
  describe "(Authentication)" do
    describe "GET 'index'" do
      it "should grant access to a staff member" do
        controller.stubs(:signed_in?).returns true
        controller.stubs(:current_user).returns @staff
        get :index, :project_id => 10, :deliverable_id => 11
        response.should render_template("reviews/index")
      end
      it "should not grant access to a student" do
        controller.stubs(:signed_in?).returns true
        controller.stubs(:current_user).returns Eit.new
        get :index, :project_id => 10, :deliverable_id => 11
        flash["error"].should_not be_empty
        response.should redirect_to("navigate back")
      end
      it "should not grant access to a user" do
        controller.stubs(:signed_in?).returns true
        controller.stubs(:current_user).returns User.new
        get :index, :project_id => 10, :deliverable_id => 11
        flash["error"].should_not be_empty
        response.should redirect_to("navigate back")
      end
      it "should not grant access to a not logged in user" do
        controller.stubs(:signed_in?).returns false
        get :index, :project_id => 10, :deliverable_id => 11
        response.should redirect_to("/sessions/new")
      end
    end
    describe "POST 'mass_create'" do
      it "should grant access to a staff member" do
        controller.stubs(:signed_in?).returns true
        controller.stubs(:current_user).returns @staff
        post :mass_create, :project_id => 10, :deliverable_id => 11, :submissions => {}
        response.should redirect_to("/projects/10/deliverables/11/reviews")
      end
      it "should not grant access to a student" do
        controller.stubs(:signed_in?).returns true
        controller.stubs(:current_user).returns Eit.new
        post :mass_create, :project_id => 10, :deliverable_id => 11
        flash["error"].should_not be_empty
        response.should redirect_to("navigate back")
      end
      it "should not grant access to a user" do
        controller.stubs(:signed_in?).returns true
        controller.stubs(:current_user).returns User.new
        post :mass_create, :project_id => 10, :deliverable_id => 11
        flash["error"].should_not be_empty
        response.should redirect_to("navigate back")
      end
      it "should not grant access to a not logged in user" do
        controller.stubs(:signed_in?).returns false
        post :mass_create, :project_id => 10, :deliverable_id => 11
        response.should redirect_to("/sessions/new")
      end
    end
  end

  describe "(Functional)" do
    before(:each) do
      controller.stubs(:signed_in?).returns true
      controller.stubs(:current_user).returns @staff
    end
    describe "GET 'index'" do
      before(:each) do
        @sub1 = Submission.new
        @sub2 = Submission.new
        @deliverable.stubs(:latest_version).returns [@sub1, @sub2]
      end
      it "should load the deliverable that the reviews belong to" do
        Deliverable.expects(:find).with(11).returns @deliverable
        get :index, :project_id => 10, :deliverable_id => 11
        assigns[:deliverable].should == @deliverable
        assigns[:submissions].should == @deliverable.latest_version
        @sub1.review.should_not be_nil
        @sub2.review.should_not be_nil
        response.should render_template("reviews/index")
      end
    end
    describe "POST 'mass_create'" do
      before(:each) do
        Deliverable.stubs(:find).with("11").returns @deliverable
        Submission.stubs(:update)
      end
      it "should load the deliverable that the reviews belong to" do
        Deliverable.expects(:find).with("11").returns @deliverable
        post :mass_create, :project_id => "10", :deliverable_id => "11", :submissions => {"7"=>{"review_attributes"=>{"percentage"=>"99", "remarks"=>""}}}
      end
      it "should redirect to the review index path" do
        post :mass_create, :project_id => "10", :deliverable_id => "11", :submissions => {"7"=>{"review_attributes"=>{"percentage"=>"99", "remarks"=>""}}}
        response.should redirect_to("/projects/10/deliverables/11/reviews")
      end
      it "should assign the current user as the reviewer if creating a new review through nested parameters" do
        Submission.expects(:update).with(["7"], ["review_attributes"=>{"percentage"=>"99", "remarks"=>"", "reviewer_id" => "11"}])
        post :mass_create, :project_id => "10", :deliverable_id => "11", :submissions => {"7"=>{"review_attributes"=>{"percentage"=>"99", "remarks"=>""}}}
      end
    end
  end

end
