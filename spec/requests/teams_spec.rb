require 'spec_helper'

feature "Teams", %q{
  In order to conduct team projects 
  As a staff member
  I want to be able to create teams and assign users to them 
} do


  background do
    Staff.create(:first_name => "Some", :last_name => "Fellow",  :identifier_url => "http://someidentifier.url/1234", :email => "some.fellow@meltwater.org")
    c2022 = ClassOf.create(:year => 2022)
    s2022 = Semester.create(:class_of => c2022, :nr => 3)
    c2023 = ClassOf.create(:year => 2023)
    s2023 = Semester.create(:class_of => c2023, :nr => 1)
    @e1 = Eit.create(:first_name => "Some",   :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",   :class_of => c2022)
    @e2 = Eit.create(:first_name => "Second", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "second.eit@meltwater.org", :class_of => c2022)
    @e3 = Eit.create(:first_name => "Third",  :last_name => "Student", :identifier_url => "http://someidentifier.url/ijkl", :email => "third.eit@meltwater.org",  :class_of => c2022)
    @e4 = Eit.create(:first_name => "Fourth", :last_name => "Student", :identifier_url => "http://someidentifier.url/mnop", :email => "fourth.eit@meltwater.org", :class_of => c2022)
    @e5 = Eit.create(:first_name => "Fifth",  :last_name => "Student", :identifier_url => "http://someidentifier.url/qrst", :email => "fifth.eit@meltwater.org",  :class_of => c2022)
    @e6 = Eit.create(:first_name => "Sixth",  :last_name => "Student", :identifier_url => "http://someidentifier.url/uvwx", :email => "sixth.eit@meltwater.org",  :class_of => c2022)
    @e7 = Eit.create(:first_name => "Young",  :last_name => "Student", :identifier_url => "http://someidentifier.url/yzab", :email => "young.eit@meltwater.org",  :class_of => c2023)
    @tp = TeamProject.create(:title => "There is no I in Team", :semester => s2022, :start => DateTime.parse("2021-09-02T09:00+00:00"))
  end

  scenario "One team with two members, shows up like expected" do
    team = Team.new(:team_project => @tp, :team_memberships => [])
    mem1 = TeamMembership.create(:team => team, :eit => @e1)
    mem2 = TeamMembership.create(:team => team, :eit => @e2)
    team.team_memberships << mem1
    team.team_memberships << mem2
    team.save
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("Teams (1)")
    page.should have_content("Some Student")
    page.should have_content("Second Student")
  end 
  scenario "An Eit is still unassigned, a link to add a team shows up next to Teams headline" do
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_link("+", :href => "/projects/1/teams/new")
    page.should have_content("Teams (0)")
    page.first("h2", :text => "Teams (0)").click_link("+")
    current_url.should == "http://www.example.com/projects/1/teams/new"
  end
  scenario "All Eits are assigned, there is no link to add a team showing up next to Teams headline" do
    team1 = Team.new(:team_project => @tp, :team_memberships => [])
    mem1 = TeamMembership.create(:team => team1, :eit => @e1)
    mem2 = TeamMembership.create(:team => team1, :eit => @e2)
    mem3 = TeamMembership.create(:team => team1, :eit => @e3)
    mem4 = TeamMembership.create(:team => team1, :eit => @e4)
    team1.team_memberships << mem1
    team1.team_memberships << mem2
    team1.team_memberships << mem3
    team1.team_memberships << mem4
    team1.save
    team2 = Team.new(:team_project => @tp, :team_memberships => [])
    mem5 = TeamMembership.create(:team => team2, :eit => @e5)
    mem6 = TeamMembership.create(:team => team2, :eit => @e6)
    team2.team_memberships << mem5
    team2.team_memberships << mem6
    team2.save
    visit "/testlogin/1"
    visit "/projects/1"
    page.should have_content("Teams (2)")
    page.should_not have_link("+", :href => "/projects/1/teams/new")
  end 
  scenario "There are six unassigned Eits, in the first team I add three, in the second team I add the remaining two, they show up as expected." do
    visit "/testlogin/1"
    visit "/projects/1"

    page.should have_content("Teams (0)")
    page.first("h2", :text => "Teams (0)").click_link("+")
    current_url.should == "http://www.example.com/projects/1/teams/new"
    select("Some Student", :from => "team_team_memberships_attributes_0_eit_id")
    select("Second Student", :from => "team_team_memberships_attributes_1_eit_id")
    select("Fourth Student", :from => "team_team_memberships_attributes_2_eit_id")
    find_button("Create Team").click

    page.should have_content("Teams (1)")
    page.should have_content("Some Student")
    page.should have_content("Second Student")
    page.should have_content("Fourth Student")
    page.first("h2", :text => "Teams (1)").click_link("+")
    select("Third Student", :from => "team_team_memberships_attributes_0_eit_id")
    select("Fifth Student", :from => "team_team_memberships_attributes_1_eit_id")
    select("Sixth Student", :from => "team_team_memberships_attributes_2_eit_id")
    find_button("Create Team").click

    page.should have_content("Teams (2)")
    page.should have_content("Some Student")
    page.should have_content("Second Student")
    page.should have_content("Third Student")
    page.should have_content("Fourth Student")
    page.should have_content("Fifth Student")
    page.should have_content("Sixth Student")
    page.should_not have_link("+", :href => "/projects/1/teams/new")
  end
end

feature "Teams", %q{
  In order to take part in team projects 
  As an Eit
  I want to be able to see my teammates
} do


  background do
    c2022 = ClassOf.create(:year => 2022)
    s2022 = Semester.create(:class_of => c2022, :nr => 3)
    c2023 = ClassOf.create(:year => 2023)
    s2023 = Semester.create(:class_of => c2023, :nr => 1)
    @e1 = Eit.create(:first_name => "Some",   :last_name => "Student", :identifier_url => "http://someidentifier.url/abdc", :email => "some.eit@meltwater.org",   :class_of => c2022)
    @e2 = Eit.create(:first_name => "Second", :last_name => "Student", :identifier_url => "http://someidentifier.url/efgh", :email => "second.eit@meltwater.org", :class_of => c2022)
    @e3 = Eit.create(:first_name => "Third",  :last_name => "Student", :identifier_url => "http://someidentifier.url/ijkl", :email => "third.eit@meltwater.org",  :class_of => c2022)
    @e4 = Eit.create(:first_name => "Fourth", :last_name => "Student", :identifier_url => "http://someidentifier.url/mnop", :email => "fourth.eit@meltwater.org", :class_of => c2022)
    @tp = TeamProject.create(:title => "There is no I in Team", :semester => s2022, :start => DateTime.parse("2021-09-02T09:00+00:00"))
  end

  scenario "Two teams with two members each, I am not assigned yet, I see a message stating that" do #TODO: Teamprojects that are not fully assigned yet should not be visible to Eits 
    visit '/testlogin/1'
    visit '/projects/1'
    page.should have_content("My Team")
    page.should have_content("Not assigned to a team yet.")
  end
  scenario "Two teams with two members each, I only see my team with two members" do
    team1 = Team.new(:team_project => @tp, :team_memberships => [])
    mem1 = TeamMembership.create(:team => team1, :eit => @e1)
    mem2 = TeamMembership.create(:team => team1, :eit => @e2)
    team1.team_memberships << mem1
    team1.team_memberships << mem2
    team1.save
    team2 = Team.new(:team_project => @tp, :team_memberships => [])
    mem3 = TeamMembership.create(:team => team2, :eit => @e3)
    mem4 = TeamMembership.create(:team => team2, :eit => @e4)
    team2.team_memberships << mem3
    team2.team_memberships << mem4
    team2.save
    visit '/testlogin/1'
    visit '/projects/1'
    page.should have_content("Some Student")
    page.should have_content("Second Student")
    page.should have_content("My Team")
    page.should_not have_content("Third Team")
    page.should_not have_content("Fourth Student")
  end
end
