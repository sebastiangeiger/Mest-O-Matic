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

  scenario "Go to a project site, no deliverable has been added yet. Add a submission, come back, the site tells you that there is one version submitted" do
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
    page.should have_content("You submitted 1 version(s)")
  end
  scenario "Add a file with invalid file type"
  scenario "Eit that is not in the class tries to gain access"
  scenario "Add a file that has already been uploaded"
end

feature "Submission", %q{
  In order to monitor the progress that my Eits are making
  As a Staff member
  I want to see an overview of files submitted for a deliverable
} do

  scenario "Three out of seven Eits in one class submitted a version"
  scenario "No Eit submitted a version"
  scenario "All seven Eits submitted a version"
  scenario "Adding a submission results in rejection"

end
