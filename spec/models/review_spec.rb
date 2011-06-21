require_relative '../spec_helper.rb'

describe Review do
  before(:each) do
    @sub = Submission.new
    @sub.stubs(:id).returns 13
    @staff = Staff.new
  end
  
  it "should be valid with a solution and a reviewer" do
    Review.create(:submission => @sub, :reviewer => @staff).should be_valid
  end
  it "should not be valid without a solution" do
    Review.create(:reviewer => @staff).should_not be_valid
  end
  it "should not be valid without a reviewer" do
    Review.create(:submission => @sub).should_not be_valid
  end
  it "should not be valid with a reviewer being an Eit" do
    lambda{Review.create(:submission => @sub, :reviewer => Eit.new)}.should raise_error
  end
  it "should not create a second review that belongs to the same Submission" do
    Review.create(:submission => @sub, :reviewer => @staff).should be_valid
    Review.create(:submission => @sub, :reviewer => @staff).should_not be_valid
  end
end
