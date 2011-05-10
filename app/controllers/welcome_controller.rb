class WelcomeController < ApplicationController
  def index
    render "sessions/current"
  end

end
