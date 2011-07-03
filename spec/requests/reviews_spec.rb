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
    @firstSemester = Semester.create(:class_of => youngerClass, :nr => 1)
    @staff = Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
         Eit.create(:first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",    :class_of => olderClass)
    e1 = Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => youngerClass)
    e2 = Eit.create(:first_name => "Second",  :last_name => "Student", :identifier_url => "http://someidentifier.url/ijkl", :email => "second.eit@meltwater.org",  :class_of => youngerClass)
    @e3 = Eit.create(:first_name => "Third",   :last_name => "Student", :identifier_url => "http://someidentifier.url/mnop", :email => "third.eit@meltwater.org",   :class_of => youngerClass)
    @second_staff = Staff.create(:first_name => "Another", :last_name => "Staff",  :identifier_url => "http://someidentifier.url/4567", :email => "another.staff@meltwater.org")
    a1 = Assignment.create(:title => "First Project", :semester => @firstSemester, :start => DateTime.now-1.weeks)
    @d1 = Deliverable.create(:title => "A past Deliverable for the First Project", :start_date => DateTime.now-2.days, :end_date => DateTime.now-1.hours, :project => a1, :author => @staff)
    d2 = Deliverable.create(:title => "A future Deliverable for the First Project", :start_date => DateTime.now-1.days, :end_date => DateTime.now+2.hours, :project => a1, :author => @staff)
    sol1 = Solution.where(:deliverable_id => @d1.id, :user_id => e1.id).first
    sol2 = Solution.where(:deliverable_id => @d1.id, :user_id => e2.id).first
    @sol3 = Solution.where(:deliverable_id => @d1.id, :user_id => @e3.id).first
    @zipFile = File.new(Rails.root + 'spec/fixtures/files/zip_file.zip')
    @zipFileDifferent = File.new(Rails.root + 'spec/fixtures/files/zip_file_different.zip')
    @sub1 = FileSubmission.create(:solution => sol1, :archive => @zipFile)
    @sub2 = FileSubmission.create(:solution => sol2, :archive => @zipFile)
  end

  scenario "Login as a staff member, go to a projects page, a project that is finished shows a link to enter grades" do
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("Deliverables (2)")
    page.should have_link("Enter Grades", :href => "/projects/1/deliverables/1/reviews")
  end

  scenario "Three out of three Eits have handed in a submission. I Login as a staff member, go to a valid deliverable review site, it has boxes for every eit" do
    @sub3 = FileSubmission.create(:solution => @sol3, :archive => @zipFile)
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
    fill_in("submissions_7_review_attributes_percentage", :with => 99) #TODO: Stop hardcoding ids, sebastian!
    fill_in("submissions_8_review_attributes_percentage", :with => 75)
    fill_in("submissions_9_review_attributes_percentage", :with => 60)
    find_button("Save").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/reviews"
    @sub1.review.percentage.should == 99
    @sub2.review.percentage.should == 75
    @sub3.review.percentage.should == 60
  end

  scenario "Login as a staff member A, the deliverable was created by staff member B. The site should show a warning that you are not the author." do
    @sub3 = FileSubmission.create(:solution => @sol3, :archive => @zipFile)
    visit "/testlogin/#{@second_staff.id}"
    visit "/projects/1"
    find_link("Enter Grades").click
    page.should have_content("This deliverable was created by Staff Member. Are you sure you want to grade it?")
    visit "/testlogin/1"
    visit "/projects/1"
    find_link("Enter Grades").click
    page.should_not have_content("This deliverable was created by Staff Member. Are you sure you want to grade it?")
  end

  scenario "Login as a staff member, you never downloaded a version and there was never a submission. The site should not show a warning." do
    a2 = Assignment.create(:title => "Second Project", :semester => @firstSemester, :start => DateTime.now-1.weeks)
    d3 = Deliverable.create(:title => "A past Deliverable for the Second Project", :start_date => DateTime.now-2.days, :end_date => DateTime.now-1.hours, :project => a2, :author => @staff)
    visit "/testlogin/1"
    visit "/projects/2"
    page.should have_content("Second")
    find_link("Enter Grades").click
    page.should_not have_content("however the current version is")
    page.should_not have_content("latest version")
    page.should_not have_content("Download")
  end

  scenario "Login as a staff member, you never downloaded a version and there were three submissions. The site should show a warning." do
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("First")
    find_link("Enter Grades").click
    page.should have_content("You never downloaded")
    page.should have_content("Download")
  end

  scenario "Login as a staff member, you downloaded version one and there were two submissions. The site should show a warning." do
    cd = VersionDownload.create(:deliverable => @d1, :version_nr => 1, :downloader => @staff)
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("First")
    find_link("Enter Grades").click
    page.should have_content("1, however the current version is 2")
    page.should have_content("Download")
  end

  scenario "Login as a staff member, you downloaded version two and there were two submissions. The site should not show a warning." do
    cd = VersionDownload.create(:deliverable => @d1, :version_nr => 2, :downloader => @staff)
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("First")
    find_link("Enter Grades").click
    page.should_not have_content("however the current version is")
    page.should_not have_content("latest version")
    page.should_not have_content("Download")
  end

  scenario "Only two out of three Eits have handed in a submission. I Login as a staff member, go to a valid deliverable review site, it has boxes for all three eits" do
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
    fill_in("submissions_7_review_attributes_percentage", :with => 99)
    fill_in("submissions_8_review_attributes_percentage", :with => 75)
    fill_in("submissions_3_review_attributes_percentage", :with => 60)
    find_button("Save").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/reviews"
    @sub1.review.percentage.should == 99
    @sub2.review.percentage.should == 75
    @sol3.submissions.first.review.percentage.should == 60
  end

  scenario "Three out of three Eits have handed in a submission. I Login as a staff member, do some reviews, then I come back and edit one of them" do
    @sub3 = FileSubmission.create(:solution => @sol3, :archive => @zipFile)
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
    fill_in("submissions_7_review_attributes_percentage", :with => 99) #TODO: Stop hardcoding ids, sebastian!
    fill_in("submissions_8_review_attributes_percentage", :with => 75)
    fill_in("submissions_9_review_attributes_percentage", :with => 60)
    find_button("Save").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/reviews"
    @sub1.review.percentage.should == 99
    @sub2.review.percentage.should == 75
    @sub3.review.percentage.should == 60
    fill_in("submissions_8_review_attributes_percentage", :with => 76)
    find_button("Save").click
    Review.where(:submission_id => @sub2.id).first.percentage.should == 76
  end
end

feature "Review", %q{
  In order to give receive feedback
  As an EIT
  I want to be able to see my grades and download reviewed files 
} do


  background do
    olderClass = ClassOf.create(:year => DateTime.now.year)
    thirdSemester = Semester.create(:class_of => olderClass, :nr => 3)
    youngerClass = ClassOf.create(:year => DateTime.now.year+1)
    firstSemester = Semester.create(:class_of => youngerClass, :nr => 1)
    @staff = Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
         Eit.create(:first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",    :class_of => olderClass)
    e1 = Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => youngerClass)
    e2 = Eit.create(:first_name => "Second",  :last_name => "Student", :identifier_url => "http://someidentifier.url/ijkl", :email => "second.eit@meltwater.org",  :class_of => youngerClass)
    @e3 = Eit.create(:first_name => "Third",   :last_name => "Student", :identifier_url => "http://someidentifier.url/mnop", :email => "third.eit@meltwater.org",   :class_of => youngerClass)
    @second_staff = Staff.create(:first_name => "Another", :last_name => "Staff",  :identifier_url => "http://someidentifier.url/4567", :email => "another.staff@meltwater.org")
    a1 = Assignment.create(:title => "First Project", :semester => firstSemester, :start => DateTime.now-1.weeks)
    @d1 = Deliverable.create(:title => "A past Deliverable for the First Project", :start_date => DateTime.now-2.days, :end_date => DateTime.now-1.hours, :project => a1, :author => @staff)
    d2 = Deliverable.create(:title => "A future Deliverable for the First Project", :start_date => DateTime.now-1.days, :end_date => DateTime.now+2.hours, :project => a1, :author => @staff)
    sol1 = Solution.where(:deliverable_id => @d1.id, :user_id => e1.id).first
    sol2 = Solution.where(:deliverable_id => @d1.id, :user_id => e2.id).first
    @sol3 = Solution.where(:deliverable_id => @d1.id, :user_id => @e3.id).first
    @zipFile = File.new(Rails.root + 'spec/fixtures/files/zip_file.zip')
    @zipFileDifferent = File.new(Rails.root + 'spec/fixtures/files/zip_file_different.zip')
    @sub1 = FileSubmission.create(:solution => sol1, :archive => @zipFile)
    @sub2 = FileSubmission.create(:solution => sol2, :archive => @zipFile)
  end

  scenario "Login as Eit, go to a projects page, a project that is finished does not shows a link to enter grades" do
    visit "/testlogin/3"
    visit "/projects/1"
    page.should have_content("Deliverables (2)")
    page.should_not have_link("Enter Grades")
  end
  scenario "Login as Eit, try to access the review page, get turned down and redirected to the previous page" do
    visit "/testlogin/3"
    visit "/projects/1"
    visit "/projects/1/deliverables/1/reviews"
    current_url.should == "http://www.example.com/projects/1"
  end
end
