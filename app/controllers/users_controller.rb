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
	
	def leave #needs testing
		@user = User.find(params[:id])
	end 

	#needs testing
	def destroy #only admin or self can delete account. Admin needs to use his own password
		@user = User.find(params[:id])
		if params[:confirm].chomp == "I Understand"
			if current_user == @user && @user.authenticate(params[:password])
				log_out
				@user.destroy
				flash[:success] = "Your account has been deleted. We hope to see you again."
				redirect_to root_url
			elsif current_user.admin? && current_user.authenticate(params[:password])
				@user.destroy #what about user's cookie and session?
				flash[:success] = "The user has been removed."
				redirect_to users_url
			else
				flash[:error] = "Invalid Password."
				render 'leave'
			end
		else
			flash[:error] = "Please type in 'I Understand' to confirm"
			render 'leave'
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
