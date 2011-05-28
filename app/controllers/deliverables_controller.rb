class DeliverablesController < ApplicationController
  before_filter :load_project
  before_filter :ensure_signed_in
  before_filter :require_staff
  
  def new
    @deliverable = Deliverable.new
  end

  def create
    @deliverable = Deliverable.new(params[:deliverable])
    @deliverable.author_id = current_user.id
    @project.deliverables << @deliverable
    if params[:commit].eql?("cancel") or @deliverable.save
      flash[:notice] = "Successfully created the deliverable #{@deliverable.title}" if @deliverable.save
      redirect_to project_path(@project) 
    else
      @project.deliverables.delete(@deliverable)
      render :action => "new"
    end
  end

  private
    def load_project
      @project = Project.find(params[:project_id])
    end
end
