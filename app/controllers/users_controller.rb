class UsersController < ApplicationController
	before_action :logged_in_user, only: [:show, :edit, :update]
	before_action :correct_user_or_admin, only: [:show, :edit, :update]
	before_action :logged_in_admin, only: [:index]

	def index
		@users = User.paginate(page: params[:page])
	end

	def new
		@user = User.new
	end

	def show
		@user = User.find(params[:id])
	end

	def create
		@user = User.new(user_params)
		if @user.save
			log_in @user
			flash[:success] = "Welcome to Teamond!"
			redirect_to @user
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
			redirect_to @user
		else 
			render 'edit'
		end
	end

	private

	def user_params
		params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation)
	end

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
			redirect_to(root_url)
		end
	end
end
