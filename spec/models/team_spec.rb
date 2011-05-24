require 'spec_helper'

describe Team do
  before(:each) do
    @team_project = TeamProject.new
    @team_project.stubs(:id).returns 13
    @team_membership = TeamMembership.new
    @eit = Eit.new
    @eit.stubs(:id).returns 47
    @team_membership.stubs(:eit).returns @eit
  end
  it "should create a team with a team member and a team project" do
    Team.create(:team_project => @team_project, :team_memberships => [@team_membership]).should be_valid
  end
  it "should not create a team with a one team member and an assignment, raise an exception instead" do
    lambda{Team.create(:team_project => Assignment.new, :team_memberships => [@team_membership])}.should raise_exception    
  end
  it "should not create a team without team members" do
    Team.create(:team_project => @team_project).should_not be_valid
  end
  it "should not create a team without team members (empty array)" do
    Team.create(:team_project => @team_project, :team_memberships => []).should_not be_valid
  end
  it "should not create a team without a project" do
    Team.create(:team_memberships => [@team_membership]).should_not be_valid
  end
end
