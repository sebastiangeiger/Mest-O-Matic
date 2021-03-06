require 'spec_helper'

describe FileSubmission do
  before(:each) do
    @solutionA = Solution.new
    @solutionB = Solution.new
    @zipFile = File.new(Rails.root + 'spec/fixtures/files/zip_file.zip')
    @zipFile_same = File.new(Rails.root + 'spec/fixtures/files/zip_file_same.zip')
    @zipFile_different = File.new(Rails.root + 'spec/fixtures/files/zip_file_different.zip')
    @pdfFile = File.new(Rails.root + 'spec/fixtures/files/pdf_file.pdf')
  end
  it "should create a submission with a solution and an attached archive of mime type 'application/zip'" do
    FileSubmission.create(:solution => @solutionA, :archive => @zipFile).should be_valid
  end
  it "should not create a submission without an attached archive" do
    FileSubmission.create(:solution => @solutionA).should_not be_valid
  end
  it "should not create a submission without a solution" do
    FileSubmission.create(:archive => @zipFile).should_not be_valid
  end
  it "should not create a submission when the attachment mime type is 'application/pdf'" do
    FileSubmission.create(:solution => @solutionA, :archive => @pdfFile).should_not be_valid
  end
  it "should create a submission if there already exists another submission with a different file and both submissions belong to the same solution" do
    FileSubmission.create(:solution => @solutionA, :archive => @zipFile).should be_valid
    FileSubmission.create(:solution => @solutionA, :archive => @zipFile_different).should be_valid
  end
  it "should create a submission if there already exists another submission with the same file and both submissions belong to different solutions" do
    FileSubmission.create(:solution => @solutionA, :archive => @zipFile).should be_valid
    FileSubmission.create(:solution => @solutionB, :archive => @zipFile_same).should be_valid
  end
  it "should not create a submission if there already exists another submission with the same file and both submissions belong to the same solution"# do
    #submission = Submission.new
    #submission.stubs(:md5_checksum).returns("f04d5ccc65d3b21b82dce2ee9aea7d87")
    #Digest::MD5.stubs(:hexdigest).returns("f04d5ccc65d3b21b82dce2ee9aea7d87")
    #@solutionA.stubs(:submissions).returns([submission])
    #Submission.create(:solution => @solutionA, :archive => @zipFile).should_not be_valid
  #end
end
