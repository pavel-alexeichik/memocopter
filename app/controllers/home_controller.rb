class HomeController < ApplicationController
  def landing
    @user = User.new
  end

  def dashboard
  end
end
