require 'spec_helper'

feature "Project", %q{
  In order to what I need to be working on
  As an Eit
  I want to be able to find information on Projects
} do


  background do
    c2022 = ClassOf.create(:year => 2022)
    s2022 = Semester.create(:class_of => c2022, :nr => 3)
    c2023 = ClassOf.create(:year => 2023)
    s2023 = Semester.create(:class_of => c2023, :nr => 1)
    Eit.create(:first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",    :class_of => c2022)
    Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => c2023)
    Assignment.create(:title => "First Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    Quiz.create(:title => "Second Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    Assignment.create(:title => "Third Project", :semester => s2022, :start => DateTime.parse("2021-09-01T09:00+00:00"))
  end

  scenario "Login as an Eit of class 2023, list all projects for the class of 2023, but not for class of 2022" do
    visit "/testlogin/2"
    visit "/projects"
    page.should have_content("Projects (2)")
    page.should have_content("First Project")
    page.should have_content("Second Project")
    page.should_not have_content("Third Project")
  end

  scenario "Login as an Eit of class 2022, list all projects for the class of 2022, but not for class of 2023" do
    visit "/testlogin/1"
    visit "/projects"
    page.should have_content("Projects (1)")
    page.should_not have_content("First Project")
    page.should_not have_content("Second Project")
    page.should have_content("Third Project")
    page.should_not have_link("+")
  end
  
  scenario "Login as an Eit of class 2022, access a project of class 2022, get information" do
    visit "/testlogin/1"
    visit "/projects/3"
    page.should have_content("Third Project")
    page.should have_content("Class of 2022")
  end

  scenario "Login as an Eit of class 2023, access a project of class 2022, get redirected to projects index and show an error message" do
    visit "/testlogin/1"
    visit "/projects/1"
    current_url.should == "http://www.example.com/projects"
    page.should have_content("This project is not available for you, here is a list of projects that are.")
  end

  
end

feature "Project", %q{
  In order to tell my Eits what they should submit
  As a Staff member
  I want to be able to create and manage Projects
} do

  background do
    c2022 = ClassOf.create(:year => 2022)
    s2022 = Semester.create(:class_of => c2022, :nr => 3)
    c2023 = ClassOf.create(:year => 2023)
    s2023 = Semester.create(:class_of => c2023, :nr => 1)
    Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
    Assignment.create(:title => "First Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00")).errors
    Quiz.create(:title => "Second Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    Assignment.create(:title => "Third Project", :semester => s2022, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    Subject.create(:title => "Business")
  end

  scenario "Login as a Staff member, lists all projects for all classes" do
    visit "/testlogin/1"
    visit "/projects"
    page.should have_content("Projects (3)")
    page.should have_content("First Project")
    page.should have_content("Second Project")
    page.should have_content("Third Project")
    page.should have_link("+")
  end

  scenario "Login as a Staff member, go to projects listing, click on + link, fill out the form and submit should create a new Assignment" do
    visit "/testlogin/1"
    visit "/projects"
    find_link("+").click
    current_url.should == "http://www.example.com/projects/new"
    choose "Assignment"
    fill_in "Title", :with => "New Assignment"
    fill_in "Description", :with => "Description for new assignment"
    select "Business"
    select "2022 / 3"
    select "2015", :from => "project_start_1i"
    select "September", :from => "project_start_2i"
    select "9", :from => "project_start_3i"
    find_button("create").click
    page.should have_content("Successfully created the project New Assignment")
    current_url.should == "http://www.example.com/projects/4"
    page.should have_link("+")
    find_link("+").click
    current_url.should == "http://www.example.com/projects/4/deliverables/new" #TODO It should not be possible to create a project without a deliverable
    visit "/projects"
    page.should have_content("New Assignment")
  end
end

feature "Project", %q{
  In order to what I need to be working on
  As a User
  I should not be allowed to see projects
} do

  background do
    User.create(:first_name => "Random", :last_name => "User",    :identifier_url => "http://someidentifier.url/4567",   :email => "random.user@meltwater.org")
  end

  scenario "Login as a User, shows no projects" do
    visit "/testlogin/1"
    visit "/projects"
    page.should have_content("Need to be EIT or staff") # TODO Reject users that don't have roles
  end
end
