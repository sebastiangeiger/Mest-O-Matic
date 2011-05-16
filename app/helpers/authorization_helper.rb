module AuthorizationHelper
  def require_staff
    current_user.staff?
  end

  def require_eit
    current_user.eit?
  end
end