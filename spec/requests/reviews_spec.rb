require 'spec_helper'

feature "Review", %q{
  In order to give feedback and grades to the Eits
  As a staff member
  I want to be able to enter grades and upload reviewed files 
} do


  background do
    olderClass = ClassOf.create(:year => DateTime.now.year)
    thirdSemester = Semester.create(:class_of => olderClass, :nr => 3)
    youngerClass = ClassOf.create(:year => DateTime.now.year+1)
    firstSemester = Semester.create(:class_of => youngerClass, :nr => 1)
    staff = Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
    Eit.create(:first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",    :class_of => olderClass)
    Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => youngerClass)
    a1 = Assignment.create(:title => "First Project", :semester => firstSemester, :start => DateTime.now-1.weeks)
    d1 = Deliverable.create(:title => "A past Deliverable for the First Project", :start_date => DateTime.now-2.days, :end_date => DateTime.now-1.hours, :project => a1, :author => staff)
    d2 = Deliverable.create(:title => "A future Deliverable for the First Project", :start_date => DateTime.now-1.days, :end_date => DateTime.now+2.hours, :project => a1, :author => staff)
  end

  scenario "Login as a staff member, go to a projects page, a project that is finished shows a link to enter grades" do
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("Deliverables (2)")
    page.should have_link("Enter Grades", :href => "/projects/1/deliverables/1/reviews")
    save_and_open_page
  end

end
