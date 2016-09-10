class SessionsController < Devise::SessionsController
  clear_respond_to
  respond_to :json

  def create
    self.resource = warden.authenticate(auth_options)
    sign_in(resource_name, resource) if user_signed_in?
  end

end
