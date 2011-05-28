require_relative '../spec_helper.rb'

describe ProjectsController do
  # render_views

  before(:each) do
    class_a = ClassOf.new
    class_b = ClassOf.new
    @project = Project.new(:title => "New Project")
    @projects = [@project]
    @project_with_deliverables = Project.new(:title => "Project with deliverables")
    @project_with_deliverables.stubs(:id).returns(99)
    @project_with_deliverables.stubs(:class_of).returns class_a
    @project_with_deliverables.stubs(:deliverables).returns [] 
    request.env["HTTP_REFERER"] = "navigate back"
    @staff = Staff.new
    @staff.stubs(:id).returns 43
    @eit_class_a = Eit.new
    @eit_class_a.stubs(:id).returns 53
    @eit_class_a.stubs(:class_of).returns class_a
    @eit_class_b = Eit.new
    @eit_class_b.stubs(:id).returns 54
    @eit_class_b.stubs(:class_of).returns class_b
  end

  describe "(Authentication)" do
    describe "responding to GET index" do
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @staff 
        get :index
        response.should render_template("projects/index")
      end

      it "should grant access to an eit" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @eit_class_a 
        get :index
        response.should render_template("projects/index")
      end
      
      it "should not grant access to an User" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns User.new
        get :index
        response.should redirect_to("navigate back")
      end
      
      it "should not grant access to not logged in user" do
        controller.expects(:signed_in?).returns false
        get :index
        response.should redirect_to(new_sessions_path)
      end
    end#GET:index

    describe "responding to GET new" do
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @staff 
        get :new
        response.should render_template("projects/new")
      end

      it "should not grant access to an eit" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @eit_class_a 
        get :new
        response.should redirect_to("navigate back")
      end
      
      it "should not grant access to an User" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns User.new
        get :new
        response.should redirect_to("navigate back")
      end
      
      it "should not grant access to not logged in user" do
        controller.expects(:signed_in?).returns false
        get :new
        response.should redirect_to(new_sessions_path)
      end
    end#GET:new
    
    describe "responding to GET show" do
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @staff
        Project.stubs(:find).returns @project_with_deliverables
        get :show, :id => 1
        response.should render_template("projects/show")
      end
      it "should grant access to an eit that belongs to the same class as the project" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @eit_class_a
        Project.stubs(:find).returns @project_with_deliverables
        get :show, :id => 1
        response.should render_template("projects/show")
      end
      it "should not grant access to an eit that belongs to a different class as the project" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @eit_class_b
        Project.stubs(:find).returns @project_with_deliverables
        get :show, :id => 1
        flash[:error].should_not be_empty
        response.should redirect_to("/projects")
      end
      it "should not grant access to an user" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns User.new
        Project.stubs(:find).returns @project_with_deliverables
        get :show, :id => 1
        response.should redirect_to("navigate back")
      end
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false
        Project.stubs(:find).returns @project_with_deliverables
        get :show, :id => 1
        response.should redirect_to(new_sessions_path)
      end
    end#GET:show

    describe "responding to POST create" do
      it "should grant access to a logged in user" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @staff
        post :create
        response.should_not redirect_to(new_sessions_path)
      end
      it "should not grant access to an eit" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns @eit_class_a 
        post :create
        response.should redirect_to("navigate back")
      end
      
      it "should not grant access to an User" do
        controller.expects(:signed_in?).returns true
        controller.stubs(:current_user).returns User.new
        post :create
        response.should redirect_to("navigate back")
      end
      
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false
        post :create
        response.should redirect_to(new_sessions_path)
      end
    end#POST:create
    
  end#Authentication
  
  describe "(Functional)" do
    before(:each) do
      controller.stubs(:signed_in?).returns true
      controller.stubs(:current_user).returns @staff 
    end

    describe "responding to GET index" do
      it "should load all projects and render index template" do
        Project.expects(:for_user).returns @projects
        get :index
        #assigns[:projects].should == @projects
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
        
        it "should pass the type params to the project item with valid params" do
          post :create, :project => {:title => "Some Quiz", :type => "Quiz"}
          assigns[:project].type.should == "Quiz"
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
