module AuthorizationHelper
  def require_staff
    current_user.type.eql?("Staff")
  end

  def require_eit
    current_user.type.eql?("Eit")
  end
end