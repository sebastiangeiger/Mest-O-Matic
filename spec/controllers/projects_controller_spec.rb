require_relative '../spec_helper.rb'

describe ProjectsController do
  render_views

  before(:each) do
    @project = Project.new(:title => "New Project")
    @projects = [@project]
    @project_with_deliverables = Project.new(:title => "Project with deliverables")
    @project_with_deliverables.stubs(:id).returns(99)
    @project_with_deliverables.stubs(:deliverables).returns [] 
  end

  describe "(Authentication)" do
    describe "responding to GET index" do
      it "should grant access to a logged in user" do
        controller.stubs(:signed_in?).returns true
        get :index
        response.should render_template("projects/index")
      end

      it "should not grant access to not logged in user" do
        controller.stubs(:signed_in?).returns false
        get :index
        response.should redirect_to(new_sessions_path)
      end
    end#GET:index

    describe "responding to GET new" do
      it "should grant access to a logged in user" do
        controller.stubs(:signed_in?).returns true
        get :new
        response.should render_template("projects/new")
      end

      it "should not grant access to a not logged in user" do
        controller.stubs(:signed_in?).returns false
        get :new
        response.should redirect_to(new_sessions_path)
      end
    end#GET:new
    
    describe "responding to GET show" do
      it "should grant access to a logged in user" do
        controller.stubs(:signed_in?).returns true
        Project.stubs(:find).returns @project_with_deliverables
        get :show, :id => 1
        response.should render_template("projects/show")
      end
      it "should not grant access to a not logged in user" do
        controller.stubs(:signed_in?).returns false
        Project.stubs(:find).returns @project_with_deliverables
        get :show, :id => 1
        response.should redirect_to(new_sessions_path)
      end
    end#GET:show

    describe "responding to POST create" do
      it "should grant access to a logged in user" do
        controller.stubs(:signed_in?).returns true
        post :create
        response.should_not redirect_to(new_sessions_path)
      end
      it "should not grant access to a not logged in user" do
        controller.stubs(:signed_in?).returns false
        post :create
        response.should redirect_to(new_sessions_path)
      end
    end#POST:create
    
  end#Authentication
  
  describe "(Functional)" do
    before(:each) do
      controller.stubs(:signed_in?).returns true
    end

    describe "responding to GET index" do
      it "should load all projects and render index template" do
        Project.expects(:all).returns @projects
        get :index
        assigns[:projects].should == @projects
        response.should render_template("projects/index")
      end
    end#GET:index

    describe "responding to GET new" do
      it "should create a new project and render the new template" do
        get :new
        assigns[:project].should_not be_nil
        assigns[:project].should be_new_record
        response.should render_template("projects/new")
      end
    end#GET:new

    describe "responding to GET show" do
      it "should load a specific project and render the show template" do
        Project.expects(:find).with(1).returns @project
        @project.stubs(:id).returns(1)
        get :show, :id => 1
        assigns[:project].should == @project
        response.should render_template("projects/show")
      end
    end#GET:show

    describe "responding to POST create" do
      describe "with valid parameters" do
        it "should create a new project" do
          Project.expects(:new).returns(@project)
          @project.expects(:save).returns(true)
          @project.expects(:id).at_least_once.returns(83)
          get :create
          response.should redirect_to(project_path(@project))
        end

        it "should pass the params to the project item with valid params" do
          post :create, :project => {:title => "Some Project"}
          assigns[:project].title.should == "Some Project"
        end
      end
      describe "with invalid parameters" do
        it "should render the new template with invalid params" do
          Project.expects(:new).returns(@project)
          @project.expects(:save).returns(false)
          get :create
          response.should render_template("projects/new")
        end
      end
    end#POST:create
  end#Functional
  
end#ProjectsController