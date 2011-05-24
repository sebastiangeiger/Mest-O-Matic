class TeamsController < ApplicationController
  before_filter :ensure_signed_in
  before_filter :require_staff, :only => [:new, :create]
  before_filter :load_project
  
  def new
    @team = Team.new
    [@project.unassigned_eits.size, 5].min.times { @team.team_memberships.build }
  end

  def create
    @team = Team.new(params[:team])
    @project.teams << @team
    if @team.save
      flash[:notice] = "Created new team"
      redirect_to project_teams_path(@project)
    else
      render :action => "new"
    end
  end

  def index
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
    
end
