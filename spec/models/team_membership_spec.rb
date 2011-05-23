require 'spec_helper'

describe TeamMembership do
  before(:each) do
    @eit = Eit.new
    @eit.stubs(:id).returns 11
    @eitB = Eit.new
    @eit.stubs(:id).returns 12
    @team_project = TeamProject.new
    @team_project.stubs(:id).returns 31
    @team = Team.new
    @teamB = Team.new
    @team.stubs(:id).returns 87
    @team.stubs(:team_project).returns @team_project
    @team_project.stubs(:teams).returns [@team]
  end
  
  it "should create a membership with one eit and one team" do
    TeamMembership.create(:eit => @eit, :team => @team).should be_valid
  end
  it "should not create a membership without an eit" do
    TeamMembership.create(:team => @team).should_not be_valid
  end
  it "should not create a membership without a team" do
    TeamMembership.create(:eit => @eit).should_not be_valid
  end
  it "should create a membership with two eits and one team" do
    TeamMembership.create(:eit => @eit, :team => @team).should be_valid
    TeamMembership.create(:eit => @eitB, :team => @team).should be_valid
  end
  it "should create memberships with one eit and the same team twice" do
    TeamMembership.create(:eit => @eit, :team => @team).should be_valid
    TeamMembership.create(:eit => @eit, :team => @team).should_not be_valid    
  end
  it "should create memberships with one eit and two teams for different projects" do
    @teamB.stubs(:eits).returns [@eit]
    @team.stubs(:eits).returns []
    @team_projectB = TeamProject.new
    @team_projectB.stubs(:teams).returns [@teamB]
    @team_project.stubs(:teams).returns [@team]
    @team.stubs(:team_project).returns @team_project
    @teamB.stubs(:team_project).returns @team_projectB
    TeamMembership.create(:eit => @eit, :team => @team).should be_valid
  end
  it "should not create a membership with one eit that is on two teams for the same project" do
    @team.stubs(:eits).returns [@eit]
    @teamB.stubs(:eits).returns [@eitB]
    @team_project.stubs(:teams).returns [@team, @teamB]
    @team.stubs(:team_project).returns @team_project
    @teamB.stubs(:team_project).returns @team_project
    TeamMembership.create(:eit => @eit, :team => @teamB).should_not be_valid
  end
end
