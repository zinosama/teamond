class UsersController < ApplicationController

	private

	def user_params
		params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation)
	end
end
