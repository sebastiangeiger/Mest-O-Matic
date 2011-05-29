class SubmissionsController < ApplicationController
  before_filter :load_deliverable
  before_filter :ensure_signed_in
  before_filter :reject_staff
  before_filter :require_eit
  before_filter :ensure_project_visible_to_eit
  
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
      @project = @deliverable.project
    end
    def reject_staff
      if current_user.staff? then
        flash[:error] = "Only available to Eits"
        redirect_to project_path(@project)
      end
    end
end
