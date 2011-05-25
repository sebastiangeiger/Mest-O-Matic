class TeamsController < ApplicationController
  before_filter :ensure_signed_in
  before_filter :require_staff, :only => [:new, :create]
  before_filter :load_project
  before_filter :ensure_team_project
  
  def new
    @team = Team.new
    [@project.unassigned_eits.size, 5].min.times { @team.team_memberships.build }
  end

  def create
    @team = Team.new(params[:team])
    @project.teams << @team
    if @team.save
      flash[:notice] = "Created new team"
      redirect_to project_path(@project)
    else
      render :action => "new"
    end
  end

  private
    def load_project
      @project = Project.where(:id => params[:project_id]).first
    end
    
    def require_staff
      unless current_user.staff? then
        flash[:error] = "Not enough privileges"
        redirect_to :back
      end
    end
    
    def ensure_team_project
      unless @project.is_a? TeamProject then
        flash[:notice] = "This project is an individual #{@project.type.capitalize}, it does not have teams."
        redirect_to project_path(@project)
      end
    end
end
