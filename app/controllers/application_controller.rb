class ApplicationController < ActionController::Base
  # rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
  #   render :text => exception, :status => 500
  # end
  protect_from_forgery
  
  # before_filter :authenticate_user!
  
  private

   # Overwriting the sign_out redirect path method
   def after_sign_out_path_for(resource_or_scope)
     new_user_session_path
   end
   
   def after_sign_in_path_for(resource)
     stored_location_for(resource) || site_home_path
   end
end
