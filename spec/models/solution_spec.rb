require 'spec_helper'

describe Solution do
  before(:each) do
    @deliverable = Deliverable.new
    @deliverable.stubs(:id).returns(1)
    @another_deliverable = Deliverable.new
    @another_deliverable.stubs(:id).returns(2)
    @user = User.new
    @user.stubs(:id).returns(3)
    @another_user = User.new
    @another_user.stubs(:id).returns(4)
  end
  
  it "should create a solution with a deliverable and a user" do
    Solution.create(:deliverable => @deliverable, :user => @user).should be_valid
  end
  it "should not create a solution without a deliverable" do
    Solution.create(:user => @user).should_not be_valid
  end
  it "should not create a solution without a user" do
    Solution.create(:deliverable => @deliverable).should_not be_valid
  end
  it "should create a solution which uses the same deliverable as another solution but a different user" do
    Solution.create(:deliverable => @deliverable, :user => @user).should be_valid
    Solution.create(:deliverable => @deliverable, :user => @another_user).should be_valid    
  end
  it "should create a solution which uses the same user as another solution but a different deliverable" do
    Solution.create(:deliverable => @deliverable, :user => @user).should be_valid
    Solution.create(:deliverable => @another_deliverable, :user => @user).should be_valid    
  end
  it "should not create a second solution with an identical deliverable user pair" do
    Solution.create(:deliverable => @deliverable, :user => @user).should be_valid
    Solution.create(:deliverable => @deliverable, :user => @user).should_not be_valid        
  end
  
  describe "#find_or_create" do
    before(:each) do
      @user = User.new
      @user.stubs(:id).returns(13)
      @deliverable = Deliverable.new
      @deliverable.stubs(:id).returns(14)
      @solution = Solution.new      
    end
    it "should find a record if there is an existing one" do
      @solution.stubs(:deliverable_id).returns(14)
      @solution.stubs(:user_id).returns(13)
      Solution.expects(:all).returns [@solution]
      Solution.find_or_create(:deliverable => @deliverable, :user => @user).should == @solution
    end
    it "should create a record if there is no existing one" do
      Solution.expects(:all).returns []
      new_solution = Solution.find_or_create(:deliverable => @deliverable, :user => @user)
      new_solution.should_not be_nil
      new_solution.should_not be_new_record
      new_solution.user.should == @user
      new_solution.deliverable.should == @deliverable
    end
  end
end
