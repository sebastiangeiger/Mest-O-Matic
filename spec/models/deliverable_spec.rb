require_relative '../spec_helper.rb'

describe Deliverable do
  before(:each) do
    @project = Project.new
    @project.stubs(:id).returns(1)
    @project_2 = Project.new
    @project_2.stubs(:id).returns(2)
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

end