class UsersController < ApplicationController
  before_filter :find_user, :only => [:edit, :update]
  before_filter :ensure_signed_in
  before_filter :ensure_same_user_as_signed_in_user, :only => [:edit, :update]
  before_filter :require_staff, :only => [:assign_roles, :unassigned_roles]
  
  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect = session[:redirect_to]
      session[:redirect_to] = nil if redirect
      flash[:notice] = "Your account has been updated"
      redirect_to(redirect || root_path)
    else
      render :action => "edit"
    end
  end

  def unassigned_roles
    @users = User.all_unassigned
    # @users = User.all
  end

  def assign_roles
    params[:users].each_pair do |user_id, hash|
      if hash[:type] and matchdata = hash[:type].match(/Eit - Class of (\d{4})/) then
        hash[:type] = "Eit"
        hash[:class_of] = ClassOf.find_by_year(matchdata[1].to_i)
      end
    end
    @users = User.update(params[:users].keys, params[:users].values).reject{|u| u.errors.empty?}
    if @users.empty?
      flash[:notice] = "Roles assigned"
      redirect_to unassigned_roles_users_path
    else
      render :action => "unassigned_roles"
    end
  end

  private
    def find_user
      @user = User.find(params[:id])
    end
    
    def ensure_same_user_as_signed_in_user
      unless @user.id.eql?(current_user.id) then
        flash[:error] = "Not enough privileges to edit this user. Here is your profile"
        redirect_to(edit_user_path(current_user))
      end
    end
    
    def require_staff
      unless current_user.staff? then
        flash[:error] = "Not enough privileges"
        redirect_to root_path
      end
    end
end
