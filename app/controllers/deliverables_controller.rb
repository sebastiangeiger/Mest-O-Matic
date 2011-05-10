class DeliverablesController < ApplicationController
  before_filter :ensure_signed_in
  before_filter :load_project_and_deliverables
  
  def load_project_and_deliverables
    @project = Project.find(params[:project_id])
  end

  def new
    @deliverable = Deliverable.new
  end

  def create
    @deliverable = Deliverable.new(params[:deliverable])
    @project.deliverables << @deliverable
    if params[:commit].eql?("cancel") or @deliverable.save
      flash[:notice] = "Successfully created the deliverable #{@deliverable.title}" if @deliverable.save
      redirect_to project_path(@project) 
    else
      @project.deliverables.delete(@deliverable)
      render :action => "new"
    end
  end

end
