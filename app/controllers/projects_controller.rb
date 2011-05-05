class ProjectsController < ApplicationController
  def index
    @projects = Project.find_all
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to @project
    else
      render :action => "new"
    end
  end
  
  def show
    @project =  Project.find(params[:id])
  end
end
