require 'spec_helper'

describe Submission do
  it "should create a submission with a solution and an attached archive of mime type 'application/zip'" do
    Submission.create(:solution => Solution.new, :archive => File.new(Rails.root + 'spec/fixtures/files/project_3.zip')).should be_valid
  end
  it "should not create a submission without an attached archive" do
    Submission.create(:solution => Solution.new).should_not be_valid
  end
  it "should not create a submission without a solution" do
    Submission.create(:archive => File.new(Rails.root + 'spec/fixtures/files/project_3.zip')).should_not be_valid
  end
  it "should not create a submission when the attachment mime type is 'application/pdf'" do
    Submission.create(:solution => Solution.new, :archive => File.new(Rails.root + 'spec/fixtures/files/Analyse-Elastizitaet.pdf')).should_not be_valid
  end
end
