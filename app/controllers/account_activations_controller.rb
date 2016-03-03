class AccountActivationsController < ApplicationController
	def edit
		user = User.find_by(email: params[:email])
		if user && !user.activated? && user.authenticated?(:activation, params[:id])
			user.activate
			log_in user
			flash[:success] = "Account activated. Welcome to Teamond."
			redirect_to root_url
		else
			flash[:error] = "Invalid activation link. If you believe this is an error, please contact us. We provide reward for bug reporters :)"
			redirect_to root_url
		end
	end
end
