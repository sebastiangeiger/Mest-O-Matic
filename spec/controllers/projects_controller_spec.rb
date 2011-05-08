require_relative '../spec_helper.rb'

describe ProjectsController do
  before(:each) do
    @project = Project.new(:title => "New Project")
    @projects = [@project]
  end

  describe "responding to GET index" do
    it "should load all projects and render index template" do
      Project.should_receive(:all).and_return @projects
      get :index
      assigns[:projects].should == @projects
      response.should render_template("projects/index")
    end
  end
  
  describe "responding to GET new" do
    it "should create a new project and render the new template" do
      get :new
      assigns[:project].should_not be_nil
      assigns[:project].should be_new_record
      response.should render_template("projects/new")
    end
  end

  describe "responding to GET show" do
    it "should load a specific project and render the show template" do
      Project.should_receive(:find).with(1).and_return @project
      get :show, :id => 1
      assigns[:project].should == @project
      response.should render_template("projects/show")
    end
  end
  
  describe "responding to POST create" do
    describe "with valid parameters" do
      it "should create a new project" do
        Project.should_receive(:new).and_return(@project)
        @project.should_receive(:save).and_return(true)
        @project.should_receive(:id).at_least(:once).and_return(83)
        get :create
        response.should redirect_to(project_path(@project))
      end
    end
    describe "with invalid parameters" do
      it "should render the new template" do
        Project.should_receive(:new).and_return(@project)
        @project.should_receive(:save).and_return(false)
        get :create
        response.should render_template("projects/new")
      end      
    end
  end
end