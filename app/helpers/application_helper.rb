module ApplicationHelper
  def welcome_message
    if current_user.guest?
      'Welcome to Memocopter!'
    else
      "Welcome to Memocopter, #{current_user.display_name}!"
    end
  end
end
