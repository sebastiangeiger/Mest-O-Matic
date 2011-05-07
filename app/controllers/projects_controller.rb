class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = "Successfully created the project #{@project.title}"
      redirect_to :action => :show, :id => @project.id
    else
      render :action => "new"
    end
  end
  
  def show
    @project =  Project.find(params[:id])
  end
end
