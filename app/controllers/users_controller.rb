class UsersController < ApplicationController
	before_action :logged_in_user, only: [:edit, :update]
	before_action :valid_user, only: [:edit, :update]

	def index
		authorize User
		@users = User.paginate(page: params[:page])
	end

	def new
		authorize User
		@user = User.new
	end

	def create
		authorize User
		@user = User.new(user_create_params)
		if @user.save
			@user.send_activation_email
			redirect_and_flash(root_url, :info, "Please check your email to activate your account")
		else
			render 'new'
		end
	end

	def edit
		authorize @user
	end

	def update
		authorize @user
		@user.update_attributes(user_update_params) ? redirect_and_flash(edit_user_url(@user), :succes, "Profile updated") : render('edit')
	end

	private

	def user_create_params
		params.require(:user).permit(policy(User).permitted_attributes)
	end
	
	def user_update_params
		params.require(:user).permit(:name, :email, :phone, :wechat, :password, :password_confirmation)
	end
	
	def valid_user
		@user = User.find(params[:id])
	rescue ActiveRecord::RecordNotFound
		redirect_and_flash(menu_url, :error, "Invalid user")
	end
end
