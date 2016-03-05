class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  private 

	def logged_in_user
		unless logged_in?
			store_location
			flash[:error] = "Please log in first."
			redirect_to login_url
		end
	end

	def logged_in_admin
		unless logged_in? && current_user.admin?
			store_location
			flash[:error] = "Access denied."
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
end
