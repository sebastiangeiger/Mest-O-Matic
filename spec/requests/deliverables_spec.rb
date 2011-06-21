require 'spec_helper'

feature "Deliverable", %q{
  In order to know what I need to be working on
  As an Eit
  I want to be able to find information on the Deliverables for a project 
} do


  background do
    @zipFile = File.new(Rails.root + 'spec/fixtures/files/zip_file.zip')
    c2022 = ClassOf.create(:year => 2022)
    s2022 = Semester.create(:class_of => c2022, :nr => 3)
    c2023 = ClassOf.create(:year => 2023)
    s2023 = Semester.create(:class_of => c2023, :nr => 1)
    Eit.create(:first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",    :class_of => c2022)
    @eit = Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => c2023)
    @staff = Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
    @a1 = Assignment.create(:title => "First Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    a2 = Quiz.create(:title => "Second Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    a3 = Assignment.create(:title => "Third Project", :semester => s2022, :start => DateTime.parse("2021-09-01T09:00+00:00"))
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), shows the one deliverable that belongs to this project" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now + 1.day, :project => @a1, :author => @staff)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should have_content("A Deliverable for the First Project")
    page.should_not have_link("+")
    page.should have_link("Add Submission")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a planned Deliverable should not be visible" do
    Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now + 7.weeks, :end_date => Time.now + 8.weeks, :project => @a1, :author => @staff)
    Deliverable.create(:title => "A Second Deliverable for the First Project", :start_date => Time.now - 1.weeks, :end_date => Time.now + 1.day, :project => @a1, :author => @staff)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should_not have_content("A Deliverable for the First Project")
    page.should have_content("A Second Deliverable for the First Project")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a current Deliverable without a submission, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now + 1.day, :project => @a1, :author => @staff)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_xpath("//img[@src='/icons/notsubmitted.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a current Deliverable with a submission, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now + 1.day, :project => @a1, :author => @staff)
    FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-5.minutes)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_xpath("//img[@src='/icons/submitted.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), an ended Deliverable with a submission, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff)
    FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-2.days)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_xpath("//img[@src='/icons/submitted.png']")
    page.should have_xpath("//img[@src='/icons/clock.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), an ended Deliverable without a submission, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_xpath("//img[@src='/icons/notsubmitted-late.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), an ended Deliverable with a submission on time, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff)
    FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-2.days)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_xpath("//img[@src='/icons/submitted.png']")
    page.should have_xpath("//img[@src='/icons/clock.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), an ended Deliverable with a submission too late, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff)
    FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_xpath("//img[@src='/icons/submitted-late.png']")
    page.should have_xpath("//img[@src='/icons/clock.png']")
    page.should_not have_xpath("//img[@src='/icons/exclamation.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a graded Deliverable without a submission, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff, :graded => true)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_xpath("//img[@src='/icons/notsubmitted-late.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a graded Deliverable with a submission on time that was reviewed,shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff, :graded => true)
    f1 = FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-2.days)
    Review.create(:submission => f1, :reviewer => @staff, :percentage => 93)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("93%")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a graded Deliverable with a submission too late, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff, :graded => true)
    f1 = FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now)
    Review.create(:submission => f1, :reviewer => @staff, :percentage => 93)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("93%")
    page.should have_xpath("//img[@src='/icons/exclamation.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a closed Deliverable without a submission, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.months, :end_date => Time.now - 7.months + 1.week, :project => @a1, :author => @staff, :graded => true)
    visit "/testlogin/2"
    visit "/projects/1"
    save_and_open_page
    page.should have_xpath("//img[@src='/icons/failed-closed.png']")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a closed Deliverable with a submission on time that was reviewed,shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.months, :end_date => Time.now - 7.months + 1.week, :project => @a1, :author => @staff, :graded => true)
    f1 = FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-2.days)
    Review.create(:submission => f1, :reviewer => @staff, :percentage => 93)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("93%")
  end

  scenario "Login as an Eit of class 2023, show a project (class of 2023), a closed Deliverable with a submission too late, shows the correct icon" do
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.months, :end_date => Time.now - 7.months + 1.week, :project => @a1, :author => @staff, :graded => true)
    f1 = FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now)
    Review.create(:submission => f1, :reviewer => @staff, :percentage => 93)
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("93%")
    page.should have_xpath("//img[@src='/icons/exclamation.png']")
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
    @staff = Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
    @a1 = Assignment.create(:title => "First Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    a2 = Quiz.create(:title => "Second Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    a3 = Assignment.create(:title => "Third Project", :semester => s2022, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => DateTime.parse("2021-09-01T09:00+00:00"), :end_date => DateTime.parse("2021-09-08T09:00+00:00"), :project => @a1, :author => @staff)
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

  #scenario "Login as Staff, set out to add a deliverable but then decide otherwise and click cancel button takes you back to project view" do
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_content("Deliverables (1)")
    #find_link("+").click
    #current_url.should == "http://www.example.com/projects/1/deliverables/new"
    #page.should have_content("Deliverables (1)")
    ##page.should_not have_link("+") #TODO Make the + link disappear ==> _details partial
    #find_button("cancel").click
    #current_url.should == "http://www.example.com/projects/1"
    #page.should have_content("Deliverables (1)")
  #end
#
  #scenario "Login as Staff, show a project, a planned Deliverable should not be visible" do
    #Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now + 7.weeks, :end_date => Time.now + 8.weeks, :project => @a1, :author => @staff)
    #Deliverable.create(:title => "A Second Deliverable for the First Project", :start_date => Time.now - 1.weeks, :end_date => Time.now + 1.day, :project => @a1, :author => @staff)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_content("Deliverables (1)")
    #page.should_not have_content("A Deliverable for the First Project")
    #page.should have_content("A Second Deliverable for the First Project")
  #end
#
  #scenario "Login as Staff, show a project, a current Deliverable without a submission, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now + 1.day, :project => @a1, :author => @staff)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_xpath("//img[@src='/icons/notsubmitted.png']")
  #end
#
  #scenario "Login as Staff, show a project, a current Deliverable with a submission, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now + 1.day, :project => @a1, :author => @staff)
    #FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-5.minutes)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_xpath("//img[@src='/icons/submitted.png']")
  #end
#
  #scenario "Login as Staff, show a project, an ended Deliverable with a submission, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff)
    #FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-2.days)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_xpath("//img[@src='/icons/submitted.png']")
    #page.should have_xpath("//img[@src='/icons/clock.png']")
  #end
#
  #scenario "Login as Staff, show a project, an ended Deliverable without a submission, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_xpath("//img[@src='/icons/notsubmitted-late.png']")
  #end
#
  #scenario "Login as Staff, show a project, an ended Deliverable with a submission on time, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff)
    #FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-2.days)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_xpath("//img[@src='/icons/submitted.png']")
    #page.should have_xpath("//img[@src='/icons/clock.png']")
  #end
#
  #scenario "Login as Staff, show a project, an ended Deliverable with a submission too late, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff)
    #FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_xpath("//img[@src='/icons/submitted-late.png']")
    #page.should have_xpath("//img[@src='/icons/clock.png']")
    #page.should_not have_xpath("//img[@src='/icons/exclamation.png']")
  #end
#
  #scenario "Login as Staff, show a project, a graded Deliverable without a submission, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff, :graded => true)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_xpath("//img[@src='/icons/notsubmitted-late.png']")
  #end
#
  #scenario "Login as Staff, show a project, a graded Deliverable with a submission on time that was reviewed,shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff, :graded => true)
    #f1 = FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-2.days)
    #Review.create(:submission => f1, :reviewer => @staff, :percentage => 93)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_content("93%")
  #end
#
  #scenario "Login as Staff, show a project, a graded Deliverable with a submission too late, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.weeks, :end_date => Time.now - 1.day, :project => @a1, :author => @staff, :graded => true)
    #f1 = FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now)
    #Review.create(:submission => f1, :reviewer => @staff, :percentage => 93)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_content("93%")
    #page.should have_xpath("//img[@src='/icons/exclamation.png']")
  #end
#
  #scenario "Login as Staff, show a project, a closed Deliverable without a submission, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.months, :end_date => Time.now - 7.months + 1.week, :project => @a1, :author => @staff, :graded => true)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #save_and_open_page
    #page.should have_xpath("//img[@src='/icons/failed-closed.png']")
  #end
#
  #scenario "Login as Staff, show a project, a closed Deliverable with a submission on time that was reviewed,shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.months, :end_date => Time.now - 7.months + 1.week, :project => @a1, :author => @staff, :graded => true)
    #f1 = FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now-2.days)
    #Review.create(:submission => f1, :reviewer => @staff, :percentage => 93)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_content("93%")
  #end
#
  #scenario "Login as Staff, show a project, a closed Deliverable with a submission too late, shows the correct icon" do
    #d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => Time.now - 7.months, :end_date => Time.now - 7.months + 1.week, :project => @a1, :author => @staff, :graded => true)
    #f1 = FileSubmission.create(:solution => d1.solutions.first, :archive => @zipFile, :created_at => Time.now)
    #Review.create(:submission => f1, :reviewer => @staff, :percentage => 93)
    #visit "/testlogin/3"
    #visit "/projects/1"
    #page.should have_content("93%")
    #page.should have_xpath("//img[@src='/icons/exclamation.png']")
  #end
end
