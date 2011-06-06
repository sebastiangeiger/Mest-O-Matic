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
    e1 = Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => youngerClass)
    e2 = Eit.create(:first_name => "Second",  :last_name => "Student", :identifier_url => "http://someidentifier.url/ijkl", :email => "second.eit@meltwater.org",  :class_of => youngerClass)
    e3 = Eit.create(:first_name => "Third",   :last_name => "Student", :identifier_url => "http://someidentifier.url/mnop", :email => "third.eit@meltwater.org",   :class_of => youngerClass)
    a1 = Assignment.create(:title => "First Project", :semester => firstSemester, :start => DateTime.now-1.weeks)
    d1 = Deliverable.create(:title => "A past Deliverable for the First Project", :start_date => DateTime.now-2.days, :end_date => DateTime.now-1.hours, :project => a1, :author => staff)
    d2 = Deliverable.create(:title => "A future Deliverable for the First Project", :start_date => DateTime.now-1.days, :end_date => DateTime.now+2.hours, :project => a1, :author => staff)
    sol1 = Solution.create(:deliverable => d1, :user => e1)
    sol2 = Solution.create(:deliverable => d1, :user => e2)
    sol3 = Solution.create(:deliverable => d1, :user => e3)
    @zipFile = File.new(Rails.root + 'spec/fixtures/files/zip_file.zip')
    @zipFileDifferent = File.new(Rails.root + 'spec/fixtures/files/zip_file_different.zip')
    @sub1 = Submission.create(:solution => sol1, :archive => @zipFile)
    #@sub1a = Submission.create(:solution => sol1, :archive => @zipFileDifferent)
    @sub2 = Submission.create(:solution => sol2, :archive => @zipFile)
    @sub3 = Submission.create(:solution => sol3, :archive => @zipFile)
  end

  scenario "Login as a staff member, go to a projects page, a project that is finished shows a link to enter grades" do
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("Deliverables (2)")
    page.should have_link("Enter Grades", :href => "/projects/1/deliverables/1/reviews")
  end

  scenario "Three out of three Eits have handed in a submission. I Login as a staff member, go to a valid deliverable review site, it has boxes for every eit" do
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("Deliverables (2)")
    page.should have_link("Enter Grades", :href => "/projects/1/deliverables/1/reviews")
    find_link("Enter Grades").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/reviews"
    page.should have_content("First Project")
    page.should have_content("A past Deliverable for the First Project")
    page.should have_content("Grading Sheet")
    page.should have_content("Another Student")
    fill_in("submissions_1_review_attributes_percentage", :with => 99)
    fill_in("submissions_2_review_attributes_percentage", :with => 75)
    fill_in("submissions_3_review_attributes_percentage", :with => 60)
    find_button("Save").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/reviews"
    @sub1.review.percentage.should == 99
    @sub2.review.percentage.should == 75
    @sub3.review.percentage.should == 60
  end

  scenario "Login as a staff member A, the deliverable was created by staff member B. The site should show a warning that you are not the author."

  scenario "Only two out of three Eits have handed in a submission. I Login as a staff member, go to a valid deliverable review site, it has boxes for all three eits" #TODO: Change the way solutions for deliverables are created, create them when creating the deliverables
end