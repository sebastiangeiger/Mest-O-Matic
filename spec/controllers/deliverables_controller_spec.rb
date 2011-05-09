require_relative '../spec_helper.rb'

describe DeliverablesController do
  render_views
  
  before(:each) do
    @project = Project.new(:title => "Project from database")
    @project.stubs(:id).returns(11)
    Project.stubs(:find).with(11).returns @project
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
        post :create, :project_id => 11
        assigns[:project].should == @project
        assigns[:project].deliverables.should include(assigns[:deliverable])
        assigns[:deliverable].should_not be_new_record
        response.should redirect_to(project_path(@project))
        flash[:notice].should_not be_nil
      end
      
      it "should pass the params to the deliverable item" do
        post :create, :project_id => 11, :deliverable => {:title => "Some Deliverable"}
        assigns[:deliverable].title.should == "Some Deliverable"
      end
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
end