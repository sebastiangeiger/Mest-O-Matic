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

end
