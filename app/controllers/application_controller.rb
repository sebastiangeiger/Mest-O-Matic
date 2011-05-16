class ApplicationController < ActionController::Base
  include AuthenticationHelper
  include AuthorizationHelper
  protect_from_forgery
end
