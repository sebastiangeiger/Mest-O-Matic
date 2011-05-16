class SubmissionsController < ApplicationController
  before_filter :load_deliverable
  before_filter :ensure_signed_in
  
  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.new(params[:submission])
    @solution = Solution.all.select{|s| s.deliverable_id == @deliverable.id and s.user_id == current_user.id}
    if @solution.empty? then
      @solution = Solution.new
      @deliverable.solutions << @solution
      current_user.solutions << @solution
      @solution.save
      p "Created a new Solution #{@solution.inspect}"
    else
      @solution = @solution.first
      p "Loaded an existing Solution #{@solution.inspect}"
    end
    p "\n Solution: #{@solution.inspect} \n"
    if @solution then
      @solution.submissions << @submission
      if @submission.save
        redirect_to project_path(@deliverable.project), :notice => "Successfully submitted the archive #{@submission.archive_file_name} (#{@submission.id})"
      else
        render :action => "new"
      end
    else 
        flash[:error] = "Could not create a solution #{@solution.class}"
        render :action => "new"
    end
  end

  private
    def load_deliverable
      @deliverable = Deliverable.find(params[:deliverable_id])
    end
end
