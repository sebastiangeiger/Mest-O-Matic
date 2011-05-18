class SubmissionsController < ApplicationController
  before_filter :load_deliverable
  before_filter :ensure_signed_in
  
  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.new(params[:submission])
    @solution = Solution.find_or_create(:deliverable => @deliverable, :user => current_user)
    @solution.submissions << @submission
    if @submission.save
      redirect_to project_path(@deliverable.project), :notice => "Successfully submitted the archive #{@submission.archive_file_name} (#{@submission.id})"
    else
      render :action => "new"
    end
  end

  private
    def load_deliverable
      @deliverable = Deliverable.find(params[:deliverable_id])
    end
end
