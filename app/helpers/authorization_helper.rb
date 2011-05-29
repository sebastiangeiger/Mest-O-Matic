module AuthorizationHelper

  def require_staff
    unless current_user.staff? then
      flash[:error] = "Not enough privileges"
      redirect_to :back
    end
  end

  def require_eit
    unless current_user.eit? then
      flash[:error] = "Need to be EIT"
      redirect_to :back
    end
  end
  
  def require_staff_or_eit
    unless current_user.eit? or current_user.staff? then
      flash[:error] = "Need to be EIT or staff"
      redirect_to :back
    end
  end  
  
  def ensure_project_visible_to_eit
    if current_user.eit? and current_user.class_of != @project.class_of then
      redirect_to projects_path
      flash[:error] = "This project is not available for you, here is a list of projects that are."
    end
  end

end
