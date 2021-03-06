class ApplicationController < ActionController::Base
  include Pundit
  include SessionsHelper
  include Exceptions
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private 

  def user_not_authorized
  	flash[:error] = "Access denied"
  	redirect_to (request.referrer || menu_url)
  end

	def logged_in_user
		unless logged_in?
			store_location
			flash[:error] = "Please log in first"
			redirect_to login_url
		end
	end

	def logged_in_admin
		unless current_user.admin?
			flash[:error] = "Access denied"
			redirect_to root_url
		end		
	end

	def correct_user_or_admin
		user = User.find_by(id: params[:id])
		unless current_user == user || current_user.admin?
			flash[:error] = "Access denied."
			redirect_to root_url
		end
	end

	def redirect_and_flash(target_url, flash_symbol, flash_message)
		redirect_to target_url
		flash[flash_symbol] = flash_message
	end

	def user_confirmed?(confirm_param)
		confirm_param && confirm_param.downcase.chomp == "i understand"
	end
end
