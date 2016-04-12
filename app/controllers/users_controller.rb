class UsersController < ApplicationController
	before_action :logged_in_user, only: [:show, :edit, :update, :leave, :destroy]
	before_action :correct_user_or_admin, only: [:show, :edit, :update, :leave, :destroy]
	before_action :logged_in_admin, only: [:index]

	def index
		@users = User.paginate(page: params[:page])
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			@user.send_activation_email
			flash[:info] = "Please check your email to activate your account."
			redirect_to root_url
		else
			render 'new'
		end
	end

	def edit
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(user_params)
			flash[:success] = "Profile Updated."
			redirect_to edit_user_url(@user)
		else 
			render 'edit'
		end
	end

	private

	def user_params
		params.require(:user).permit(:name, :email, :phone, :wechat, :password, :password_confirmation)
	end
end
