require 'spec_helper'

describe Team do
  before(:each) do
    @team_project = TeamProject.new
    @team_project.stubs(:id).returns 13
  end
  it "should create a team with no team member and a team project" do
    Team.create(:team_project => @team_project, :team_memberships => []).should be_valid
  end
  it "should not create a team with a one team member and an assignment, raise an exception instead" do
    lambda{Team.create(:team_project => Assignment.new)}.should raise_exception    
  end
  it "should create a team without team members" do
    Team.create(:team_project => @team_project).should be_valid
  end
  it "should not create a team without a project" do
    Team.create().should_not be_valid
  end
end
