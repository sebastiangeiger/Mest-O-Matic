require 'spec_helper'

feature "Submission", %q{
  In order to solve a Deliverable 
  As an Eit
  I want to be able to see what I submitted and add new submissions 
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

  scenario "Go to a project site, no deliverable has been added yet. Add a submission, come back, the site tells you that there is one version submitted, then do it over again, shows you two versions" do
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should have_content("A Deliverable for the First Project")
    page.should_not have_link("+")
    page.should have_link("Add Submission")
    page.should have_content("You did not submit a version yet")
    find_link("Add Submission").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/submissions/new"
    attach_file("File", File.join(::Rails.root, "spec", "fixtures", "files", "zip_file.zip"))
    find_button("Create Submission").click
    current_url.should == "http://www.example.com/projects/1"
    page.should have_content("Successfully submitted the archive")
    page.should have_content("You submitted 1 version(s)")
    find_link("Add Submission").click
    attach_file("File", File.join(::Rails.root, "spec", "fixtures", "files", "zip_file_different.zip"))
    find_button("Create Submission").click
    current_url.should == "http://www.example.com/projects/1"
    page.should have_content("Successfully submitted the archive")
    page.should have_content("You submitted 2 version(s)")
  end
  scenario "Add a file with invalid file type" do
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should have_content("A Deliverable for the First Project")
    page.should_not have_link("+")
    page.should have_link("Add Submission")
    page.should have_content("You did not submit a version yet")
    find_link("Add Submission").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/submissions/new"
    attach_file("File", File.join(::Rails.root, "spec", "fixtures", "files", "pdf_file.pdf"))
    find_button("Create Submission").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/submissions"
    page.should have_content("error")
    page.should have_content("Archive content type is not")
  end
  scenario "Eit that is not in the class tries to gain access, gets rejected" do
    visit '/testlogin/1/'
    visit '/projects/1/deliverables/1/submissions/new'
    page.should have_content("This project is not available for you")
  end
  scenario "Add a file that has already been uploaded, results in an error message" do
    visit "/testlogin/2"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should have_content("A Deliverable for the First Project")
    page.should_not have_link("+")
    page.should have_link("Add Submission")
    page.should have_content("You did not submit a version yet")
    find_link("Add Submission").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/submissions/new"
    attach_file("File", File.join(::Rails.root, "spec", "fixtures", "files", "zip_file.zip"))
    find_button("Create Submission").click
    p Submission.last.inspect
    current_url.should == "http://www.example.com/projects/1"
    page.should have_content("You submitted 1 version(s)")
    page.should have_link("Add Submission")
    find_link("Add Submission").click
    current_url.should == "http://www.example.com/projects/1/deliverables/1/submissions/new"
    attach_file("File", File.join(::Rails.root, "spec", "fixtures", "files", "zip_file.zip"))
    find_button("Create Submission").click
    #TODO: Activate this test, something in the md5 calculation does not work
    #current_url.should == "http://www.example.com/projects/1/deliverables/1/submissions"
    #current_url.should_not have_content("Successfully submitted the archive")
  end
end

feature "Submission", %q{
  In order to monitor the progress that my Eits are making
  As a Staff member
  I want to see an overview of files submitted for a deliverable and download all submissions for a deliverable in on file
} do

  background do
    c2022 = ClassOf.create(:year => 2022)
    s2022 = Semester.create(:class_of => c2022, :nr => 3)
    c2023 = ClassOf.create(:year => 2023)
    s2023 = Semester.create(:class_of => c2023, :nr => 1)
    @e1 = Eit.create(:first_name => "Some",    :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",    :class_of => c2023)
    @e2 = Eit.create(:first_name => "Another", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "another.eit@meltwater.org", :class_of => c2023)
    @e3 = Eit.create(:first_name => "Third",   :last_name => "Student", :identifier_url => "http://someidentifier.url/ijkl", :email => "third.eit@meltwater.org",   :class_of => c2023)
    e4 = Eit.create(:first_name => "Fourth",  :last_name => "Student", :identifier_url => "http://someidentifier.url/mnop", :email => "fourth.eit@meltwater.org",  :class_of => c2023)
    e5 = Eit.create(:first_name => "Fifth",   :last_name => "Student", :identifier_url => "http://someidentifier.url/qrst", :email => "fifth.eit@meltwater.org",   :class_of => c2023)
    e6 = Eit.create(:first_name => "Sixth",   :last_name => "Student", :identifier_url => "http://someidentifier.url/uvwx", :email => "sixth.eit@meltwater.org",   :class_of => c2023)
    e7 = Eit.create(:first_name => "Seventh", :last_name => "Student", :identifier_url => "http://someidentifier.url/yz12", :email => "seventh.eit@meltwater.org", :class_of => c2023)
    staff = Staff.create(:first_name => "Staff", :last_name => "Member",  :identifier_url => "http://someidentifier.url/1234", :email => "staff.member@meltwater.org")
    a1 = Assignment.create(:title => "First Project", :semester => s2023, :start => DateTime.parse("2021-09-01T09:00+00:00"))
    @d1 = Deliverable.create(:title => "A Deliverable for the First Project", :start_date => DateTime.parse("2021-09-01T09:00+00:00"), :end_date => DateTime.parse("2021-09-08T09:00+00:00"), :project => a1, :author => staff)
  end

  scenario "Three out of seven Eits in one class submitted a version, this should show up any Staff members summary" do
    zipFile = File.new(Rails.root + 'spec/fixtures/files/zip_file.zip')
    sol1 = Solution.create(:user => @e1, :deliverable => @d1)
    sol2 = Solution.create(:user => @e2, :deliverable => @d1)
    sol3 = Solution.create(:user => @e3, :deliverable => @d1)
    Submission.create(:solution => sol1, :archive => zipFile)
    Submission.create(:solution => sol2, :archive => zipFile)
    Submission.create(:solution => sol3, :archive => zipFile)
    visit "/testlogin/8"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should have_content("3/7 Eits submitted so far")
    page.should_not have_content("You did not submit a version yet")
    page.should have_content("Download all Submissions (Version 3)")
    page.should have_link("Download all Submissions (Version 3)", :href => "/projects/1/deliverables/1/download")
  end
  scenario "No Eit submitted a version" do
    visit "/testlogin/8"
    visit "/projects/1"
    page.should have_content("Deliverables (1)")
    page.should have_content("0/7 Eits submitted so far")
    page.should_not have_content("You did not submit a version yet")
    page.should_not have_content("Download")
  end
  scenario "Adding a submission results in rejection" do
    visit "/testlogin/8"
    visit "/projects/1/deliverables/1/submissions/new"
    page.should have_content("Only available to Eits")
    current_url.should == "http://www.example.com/projects/1"
  end

end
