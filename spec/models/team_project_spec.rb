require 'spec_helper'

describe TeamProject do
  describe "#assigned_eits" do
    before(:each) do
      @eitA = Eit.new
      @eitB = Eit.new
      @class_of = ClassOf.new
      @class_of.stubs(:eits).returns [@eitA]
      @team_project = TeamProject.new
      @team_project.stubs(:class_of).returns @class_of
      @teamA = Team.new
      @teamB = Team.new
    end
    it "should not return an eit if he is in the class but there is not team" do
      @team_project.stubs(:teams).returns []
      @team_project.assigned_eits.should == []
    end
    it "should not return an eit if he is in the class, there is a team but it's empty" do
      @team_project.stubs(:teams).returns [@teamA]
      @team_project.assigned_eits.should == []
    end
    it "should return the eit if he is in the class, there is a team and he is on it" do
      @teamA.stubs(:eits).returns [@eitA]
      @team_project.stubs(:teams).returns [@teamA]
      @team_project.assigned_eits.should == [@eitA]      
    end
    it "should return both eits if they are in the class, there is a team and both are on it" do
      @teamA.stubs(:eits).returns [@eitA, @eitB]
      @team_project.stubs(:teams).returns [@teamA]
      @team_project.assigned_eits.should == [@eitA, @eitB]      
    end
    it "should return both eits if they are in the class, there are two teams and both are on a different one" do
      @teamA.stubs(:eits).returns [@eitA]
      @teamB.stubs(:eits).returns [@eitB]
      @team_project.stubs(:teams).returns [@teamA, @teamB]
      @team_project.assigned_eits.should == [@eitA, @eitB]            
    end
    it "should return only one eit if there are two in the class, there are two teams and but only one is on a team" do
      @teamA.stubs(:eits).returns [@eitA]
      @teamB.stubs(:eits).returns []
      @team_project.stubs(:teams).returns [@teamA, @teamB]
      @team_project.assigned_eits.should == [@eitA]            
    end
  end
  describe "#teams_for" do
    before(:each) do
      @eit = Eit.new
      @eitB = Eit.new
      @team_project = TeamProject.new
      @teamA = Team.new
      @teamB = Team.new
    end
    
    it "should return an empty array if there are no teams" do
      @team_project.teams_for(@eit).should == []
    end
    it "should return an empty array if there is a team but the eit is not on it" do
      @teamA.stubs(:eits).returns [@eitB]
      @team_project.stubs(:teams).returns [@teamA]
      @team_project.teams_for(@eit).should == []
    end
    it "should return an array with the team if there is a team and the eit is on it" do
      @teamA.stubs(:eits).returns [@eit, @eitB]
      @team_project.stubs(:teams).returns [@teamA]
      @team_project.teams_for(@eit).should == [@teamA]
    end
    it "should return an array with one team if there are two teams and the eit is on one of them it" do
      @teamA.stubs(:eits).returns [@eitB]
      @teamB.stubs(:eits).returns [@eit, @eitB]
      @team_project.stubs(:teams).returns [@teamA, @teamB]
      @team_project.teams_for(@eit).should == [@teamB]
    end
    it "should return an array with two teams if there are two teams and the eit is on both" do
      @teamA.stubs(:eits).returns [@eit, @eitB]
      @teamB.stubs(:eits).returns [@eit, @eitB]
      @team_project.stubs(:teams).returns [@teamA, @teamB]
      @team_project.teams_for(@eit).should == [@teamA, @teamB]
    end
  end
end
