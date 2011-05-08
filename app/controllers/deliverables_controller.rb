class DeliverablesController < ApplicationController
  before_filter :load_project_and_deliverables
  
  def load_project_and_deliverables
    @project = Project.find(params[:project_id])
    @deliverables = Deliverable.find_by_project_id(params[:project_id])
    puts "Loaded project and deliverables"
  end

  def new
    @deliverable = Deliverable.new
  end

  def create
    @deliverable = Deliverable.new(params[:deliverable])
    @project.deliverables << @deliverable
    if params[:commit].eql?("cancel") 
      redirect_to project_path(@project) 
    elsif @deliverable.save
      redirect_to project_path(@project), :notice => "Successfully created the deliverable #{@deliverable.title}"
    else
      @project.deliverables.delete(@deliverable)
      render :action => "new"
    end
  end

end
