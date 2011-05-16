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
    @users = User.where(:type => nil)
  end

  def assign_roles
    p params[:users].inspect
  end

  private
    def find_user
      @user = User.find(params[:id])
    end
    
    def ensure_same_user_as_signed_in_user
      unless @user.id.eql?(current_user.id) then
        flash[:error] = "Not enough priviledges to edit this user. Here is your profile"
        redirect_to(edit_user_path(current_user))
      end
    end
end
