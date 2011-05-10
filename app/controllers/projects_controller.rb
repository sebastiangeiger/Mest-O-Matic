class ProjectsController < ApplicationController
  before_filter :ensure_signed_in
  
  def index
    @projects = Project.all
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to project_path(@project), :notice => "Successfully created the project #{@project.title}"
    else
      render :action => "new"
    end
  end
  
  def show
    @project =  Project.find(params[:id])
  end
end
