require 'spec_helper'

feature "Deliverable", %q{
  In order to know what I need to be working on
  As an Eit
  I want to be able to find information on the Deliverables for a project 
} do


  background do
    c2022 = ClassOf.create(:year => 2022)
    s2022 = Semester.create(:class_of => c2022, :nr => 3)
    c2023 = ClassOf.create(:year => 2023)
    s2023 = Semester.create(:class_of => c2023, :nr => 1)
    Eit.create(:first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",    :class_of => c2022)
    Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => c2023)
    staff = Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
    a1 = Assignment.create(:title => "First Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    a2 = Quiz.create(:title => "Second Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    a3 = Assignment.create(:title => "Third Project", :semester => s2022, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => DateTime.parse("2021-09-01T09:00+00:00"), :end_date => DateTime.parse("2021-09-08T09:00+00:00"), :project => a1, :author => staff)
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), shows the one deliverable that belongs to this project" do
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should have_content("A Deliverable for the First Project")
    page.should_not have_link("+")
    page.should have_link("Add Submission")
  end

end

feature "Deliverable", %q{
  In order to tell the Eits what they should be working on
  As a Staff member
  I want to be able to add new Deliverables and view their progress
} do


  background do
    c2022 = ClassOf.create(:year => 2022)
    s2022 = Semester.create(:class_of => c2022, :nr => 3)
    c2023 = ClassOf.create(:year => 2023)
    s2023 = Semester.create(:class_of => c2023, :nr => 1)
    @e1 = Eit.create(:first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",    :class_of => c2022)
    @e2 = Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => c2023)
    staff = Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
    a1 = Assignment.create(:title => "First Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    a2 = Quiz.create(:title => "Second Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    a3 = Assignment.create(:title => "Third Project", :semester => s2022, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => DateTime.parse("2021-09-01T09:00+00:00"), :end_date => DateTime.parse("2021-09-08T09:00+00:00"), :project => a1, :author => staff)
  end

  scenario "Login as Staff, show a project, shows the one delivarable that belongs to this project, shows a button for a new Deliverable but none to add a Submission" do
    visit "/testlogin/3"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should have_content("A Deliverable for the First Project")
    page.should have_link("+")
    page.should_not have_link("Add Submission")
  end

  scenario "Login as Staff, create a new deliverable and make sure that it shows up when looking at the project" do
    visit "/testlogin/3"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    find_link("+").click
    current_url.should == "http://www.example.com/projects/1/deliverables/new"
    fill_in "Title", :with => "New Deliverable for the First Project"
    fill_in "Description", :with => "A description"
    select "2015",      :from => "deliverable_start_date_1i"
    select "September", :from => "deliverable_start_date_2i"
    select "9",         :from => "deliverable_start_date_3i"
    select "09",        :from => "deliverable_start_date_4i"
    select "00",        :from => "deliverable_start_date_5i"
    select "2015",      :from => "deliverable_end_date_1i"
    select "September", :from => "deliverable_end_date_2i"
    select "10",        :from => "deliverable_end_date_3i"
    select "09",        :from => "deliverable_end_date_4i"
    select "00",        :from => "deliverable_end_date_5i"
    find_button("create").click
    current_url.should == "http://www.example.com/projects/1"
    page.should have_content("Deliverables (2)")
  end

  scenario "Login as Staff, create a new deliverable and make sure it also created all Solutions for all users" do
    visit "/testlogin/3"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    find_link("+").click
    current_url.should == "http://www.example.com/projects/1/deliverables/new"
    fill_in "Title", :with => "New Deliverable for the First Project"
    fill_in "Description", :with => "A description"
    select "2015",      :from => "deliverable_start_date_1i"
    select "September", :from => "deliverable_start_date_2i"
    select "9",         :from => "deliverable_start_date_3i"
    select "09",        :from => "deliverable_start_date_4i"
    select "00",        :from => "deliverable_start_date_5i"
    select "2015",      :from => "deliverable_end_date_1i"
    select "September", :from => "deliverable_end_date_2i"
    select "10",        :from => "deliverable_end_date_3i"
    select "09",        :from => "deliverable_end_date_4i"
    select "00",        :from => "deliverable_end_date_5i"
    find_button("create").click
    current_url.should == "http://www.example.com/projects/1"
    p = Project.where(:id => 1).first
    d = p.deliverables.last
    p.eits.should == [@e2]
    d.title.should == "New Deliverable for the First Project"
    d.solutions.collect{|s| s.user}.should == [@e2]
  end

  scenario "Login as Staff, set out to add a deliverable but then decide otherwise and click cancel button takes you back to project view" do
    visit "/testlogin/3"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    find_link("+").click
    current_url.should == "http://www.example.com/projects/1/deliverables/new"
    page.should have_content("Deliverables (1)")
    #page.should_not have_link("+") #TODO Make the + link disappear ==> _details partial
    find_button("cancel").click
    current_url.should == "http://www.example.com/projects/1"
    page.should have_content("Deliverables (1)")
  end
end
