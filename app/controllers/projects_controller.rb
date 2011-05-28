class ProjectsController < ApplicationController
  before_filter :ensure_signed_in
  before_filter :require_staff_or_eit
  before_filter :require_staff, :only => [:new, :create]
  before_filter :load_project, :only => [:show]
  before_filter :ensure_project_visible_to_eit, :only => [:show]
  
  def index
    @projects = Project.for_user(current_user)
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(params[:project])
    @project.type = params[:project][:type] if params[:project] and params[:project][:type] #TODO: why do I need to set this?
    if @project.save
      redirect_to project_path(@project), :notice => "Successfully created the project #{@project.title}"
    else
      render :action => "new"
    end
  end
  
  def show
  end
  
  private
    def load_project
      @project =  Project.find(params[:id])
    end
    def ensure_project_visible_to_eit
      if current_user.eit? and current_user.class_of != @project.class_of then
        redirect_to projects_path
        flash[:error] = "This project is not available for you, here is a list of projects that are."
      end
    end
end
