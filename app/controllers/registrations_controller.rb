class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
    if resource.save
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        return render :json => { success: true, location: dashboard_path }
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        return render :json => { :success => true }
      end
    else
      return render :json => { success: false, error_messages: resource.errors.full_messages.to_json }
    end
  end

  def try_as_guest
    sign_in User.create_guest
    redirect_to dashboard_path
  end
end
