require 'spec_helper'

describe Submission do
  before(:each) do
    @solution = Solution.new
  end
  it "should create a submission with a solution" do
    Submission.create(:solution => @solution).should be_valid
  end
  it "should not create a submission without a solution" do
    Submission.create().should_not be_valid
  end
end
