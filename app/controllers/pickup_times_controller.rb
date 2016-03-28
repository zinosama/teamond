class PickupTimesController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin
	
	def create
		@time = PickupTime.new(pickup_time_params)
		if @time.save
			redirect_and_flash(pickup_locations_url, :success, "New delivery time saved")
		else
			@times = PickupTime.all
			@location = PickupLocation.new
			@locations = PickupLocation.all

			render 'pickup_locations/index'
		end
	end

	def edit
		@time = PickupTime.find(params[:id])
		unless @time
			redirect_and_flash(root_url, :error, "Requested delivery time does not exist")
		end
	end

	def update
		@time = PickupTime.find(params[:id])
		if @time.update_attributes(pickup_time_params)
			redirect_and_flash(pickup_locations_url, :success, "Delivery time updated")
		else
			redirect_and_flash(edit_pickup_time_url(@time), :error, "Update failed. Please contact system admin.")
		end
	end

	def destroy
		time = PickupTime.find(params[:id])
		if user_confirmed? params[:confirm_delete]
			time.destroy
			redirect_and_flash(pickup_locations_url, :success, "Delivery time has been removed")
		else
			redirect_and_flash(edit_pickup_time_url(time), :error, "Please type 'I Understand' to confirm delete")
		end
	end	

	private

	def pickup_time_params
		params.require(:pickup_time).permit(:pickup_hour, :pickup_minute, :cutoff_hour, :cutoff_minute)
	end
end
