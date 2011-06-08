require_relative '../spec_helper.rb'

describe DeliverablesController do
  # render_views
  
  before(:each) do
    @eit1 = Eit.new
    @eit2 = Eit.new
    @eit3 = Eit.new
    class_of = ClassOf.new
    class_of.stubs(:eits).returns [@eit1, @eit2, @eit3]
    @project = Project.new(:title => "Project from database")
    @project.stubs(:id).returns(11)
    @project.stubs(:class_of).returns class_of
    Project.stubs(:find).with(11).returns @project
    @user = User.new
    @user.stubs(:id).returns 53
    @staff = Staff.new
    @staff.stubs(:id).returns 73
    @eit = Eit.new
    @eit.stubs(:id).returns 63
    request.env["HTTP_REFERER"] = "navigate back"
  end
  
  describe "(Authentication)" do
    describe "responding to GET new" do
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).returns @staff
        get :new, :project_id => 11
        response.should render_template("deliverables/new")
      end
      it "should not grant access to an Eit" do
        controller.expects(:signed_in?).returns true        
        controller.expects(:current_user).returns @eit
        get :new, :project_id => 11
        response.should redirect_to("navigate back")
      end
      it "should not grant access to an User" do
        controller.expects(:signed_in?).returns true        
        controller.expects(:current_user).returns @user
        get :new, :project_id => 11
        response.should redirect_to("navigate back")
      end
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false        
        get :new, :project_id => 11
        response.should redirect_to(new_sessions_path)
      end
    end
    describe "responding to POST create" do
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).at_least(1).returns @staff
        Deliverable.any_instance.stubs(:valid?).returns true
        Deliverable.any_instance.stubs(:eits).returns [] #skip after_create filter
        post :create, :project_id => 11
        flash[:notice].should_not be_empty
        response.should redirect_to("/projects/11")
      end
      it "should not grant access to an Eit" do
        controller.expects(:signed_in?).returns true        
        controller.expects(:current_user).returns @eit
        post :create, :project_id => 11
        flash[:error].should_not be_empty
        response.should redirect_to("navigate back")
      end
      it "should not grant access to an User" do
        controller.expects(:signed_in?).returns true        
        controller.expects(:current_user).returns @user
        post :create, :project_id => 11
        response.should redirect_to("navigate back")
      end
      it "should not grant access to a not logged in user" do
        controller.expects(:signed_in?).returns false        
        post :create, :project_id => 11
        response.should redirect_to(new_sessions_path)
      end
    end
    describe "responding to GET download" do
      before(:each) do
        @deliverable = Deliverable.new
        Deliverable.stubs(:find).with(10).returns @deliverable
      end
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).at_least(1).returns @staff
        @deliverable.expects(:download_latest_version) #TODO: Is also functional test?!
        controller.expects(:send_file)
        get :download, :project_id => 11, :id => 10
      end
      it "should not grant access to an eit" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).at_least(1).returns @eit
        get :download, :project_id => 11, :id => 10
        response.should redirect_to("navigate back")
      end
      it "should not grant access to an user" do
        controller.expects(:signed_in?).returns true
        controller.expects(:current_user).at_least(1).returns @user
        get :download, :project_id => 11, :id => 10
        response.should redirect_to("navigate back")
      end
      it "should grant access to a staff member" do
        controller.expects(:signed_in?).returns false
        get :download, :project_id => 11, :id => 10
        response.should redirect_to("/sessions/new")
      end
    end
  end
  
  describe "(Functional)" do
    before(:each) do
      controller.stubs(:signed_in?).returns true
      controller.stubs(:current_user).returns @staff
    end

    describe "responding to GET new" do
      it "should create a new deliverable and load the project, the render the new template" do
        Project.expects(:find).with(11).returns @project
        get :new, :project_id => 11
        assigns[:deliverable].should_not be_nil
        assigns[:deliverable].should be_new_record
        assigns[:project].should == @project
        response.should render_template("deliverables/new")
      end
    end
  
    describe "responding to POST create" do

      it "should pass the params to the deliverable item" do
        post :create, :project_id => 11, :deliverable => {:title => "Some Deliverable"}
        assigns[:deliverable].title.should == "Some Deliverable"
      end

      describe "user clicked cancel button" do
        it "should redirect to project path and do nothing otherwise" do
          post :create, :project_id => 11, :commit => "cancel"
          response.should redirect_to(project_path(@project))
          flash[:notice].should be_nil
        end
      end
    
      describe "with valid parameters" do
        it "should create a new deliverable that is part of the current project" do      
          Deliverable.any_instance.stubs(:valid?).returns(true)
          Project.expects(:find).with(11).returns @project
          Deliverable.any_instance.stubs(:eits).returns [] #skip after_create filter
          post :create, :project_id => 11
          assigns[:project].should == @project
          assigns[:project].deliverables.should include(assigns[:deliverable])
          assigns[:deliverable].should_not be_new_record
          response.should redirect_to(project_path(@project))
          flash[:notice].should_not be_nil
        end
      
        it "should create solutions for every eit in the class" #do
          #Deliverable.any_instance.stubs(:valid?).returns(true)
          #Project.expects(:find).with(11).returns @project
          #Deliverable.any_instance.stubs(:eits).returns [@eit1, @eit2, @eit3] 
          #post :create, :project_id => 11
          #assigns[:project].should == @project
          #assigns[:deliverable].solutions.collect{|s| s.user}.should == [@eit1, @eit2, @eit3]
        #end
      end
      describe "with invalid parameters" do
        it "should render the new template" do
          Deliverable.any_instance.stubs(:valid?).returns(false)
          post :create, :project_id => 11
          response.should render_template("deliverables/new")
          assigns[:project].deliverables.should_not include(assigns[:deliverable])
          assigns[:deliverable].should be_new_record
          flash[:notice].should be_nil
        end      
      end
    end
  end#Functional
end
