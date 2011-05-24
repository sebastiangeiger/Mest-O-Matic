require 'spec_helper'

describe TeamsController do
  before(:each) do
    @staff = Staff.new
    @eit = Eit.new
    @team_project = TeamProject.new
    @team_project.stubs(:id).returns 11
    @team_project.stubs(:teams).returns []
    @team_project.stubs(:unassigned_eits).returns [@eit]
    request.env["HTTP_REFERER"] = "/go/back"
  end
  
  describe "(Authentication)" do
    before(:each) do
      Project.stubs(:where).with(:id => 11).returns [@team_project]
      Team.any_instance.stubs(:valid?).returns true
    end
    
    describe "GET 'new'" do 
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @staff
        get :new, :project_id => 11
        response.should render_template("teams/new")
      end

      it "should not grant access to an eit" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @eit
        get :new, :project_id => 11
        flash[:error].should_not be_nil
        response.should redirect_to("/go/back")
      end

      it "should not grant access to a user that is not logged in" do
        controller.expects(:signed_in?).returns false
        get :new, :project_id => 11
        response.should redirect_to("/sessions/new")
      end
    end
  
    describe "POST 'create'" do
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @staff
        post :create, :project_id => 11
        response.should redirect_to("/projects/11/teams")
      end

      it "should not grant access to an eit" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @eit
        post :create, :project_id => 11
        flash[:error].should_not be_nil
        response.should redirect_to("/go/back")
      end

      it "should not grant access to a user that is not logged in" do
        controller.expects(:signed_in?).returns false
        post :create, :project_id => 11
        response.should redirect_to("/sessions/new")
      end
    end
  
    describe "GET 'index'" do
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        get :index, :project_id => 11
        response.should render_template("teams/index")
      end

      it "should grant access to an eit" do
        controller.expects(:signed_in?).returns true
        get :index, :project_id => 11
        response.should render_template("teams/index")
      end

      it "should not grant access to a user that is not logged in" do
        controller.expects(:signed_in?).returns false
        get :index, :project_id => 11
        response.should redirect_to("/sessions/new")
      end
    end
  end

  describe "(Functional)" do
    before(:each) do
      controller.stubs(:signed_in?).returns true
      controller.stubs(:current_user).returns @staff
    end
    describe "GET 'new'" do 
      it "should render the new template for a Team Project" do
        Project.stubs(:where).with(:id => 11).returns [@team_project]
        get :new, :project_id => 11
        response.should render_template("teams/new")
      end
      it "should load a new Team instance" do
        @team = Team.new
        Team.expects(:new).returns @team
        Project.stubs(:where).with(:id => 11).returns [@team_project]
        get :new, :project_id => 11
        assigns[:team].should == @team
        response.should render_template("teams/new")
      end
      it "should load the project instance" do
        Project.expects(:where).with(:id => 11).returns [@team_project]
        get :new, :project_id => 11
        assigns[:project].should == @team_project
      end
      it "should build three TeamMemberships if there are three unassigned eits for the project" do
        @team_project.stubs(:unassigned_eits).returns [Eit.new, Eit.new, Eit.new]
        Project.stubs(:where).with(:id => 11).returns [@team_project]
        get :new, :project_id => 11
        assigns[:team].team_memberships.size.should == 3        
      end
      it "should build five TeamMemberships if there are seven unassigned eits for the project" do
        @team_project.stubs(:unassigned_eits).returns [Eit.new, Eit.new, Eit.new, Eit.new, Eit.new, Eit.new, Eit.new]
        Project.stubs(:where).with(:id => 11).returns [@team_project]
        get :new, :project_id => 11
        assigns[:team].team_memberships.size.should == 5        
      end
      it "should redirect to the assignment page if the project is of subtype assignment" do
        assignment = Assignment.new
        assignment.stubs(:id).returns 12
        Project.stubs(:where).with(:id => 12).returns [assignment]
        get :new, :project_id => 12
        flash[:notice].should_not be_empty
        response.should redirect_to("/projects/12")
      end
      it "should redirect to the quiz page if the project is of subtype quiz" do
        quiz = Quiz.new
        quiz.stubs(:id).returns 13
        Project.stubs(:where).with(:id => 13).returns [quiz]
        get :new, :project_id => 13
        flash[:notice].should_not be_empty
        response.should redirect_to("/projects/13")
      end
    end
  
    describe "POST 'create'" do
      it "should redirect to the assignment page if the project is of subtype assignment"
      it "should redirect to the quiz page if the project is of subtype quiz"
    end
  
    describe "GET 'index'" do
      it "should redirect to the assignment page if the project is of subtype assignment"
      it "should redirect to the quiz page if the project is of subtype quiz"
    end
  end

end
