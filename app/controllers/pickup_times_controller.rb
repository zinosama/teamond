class PickupTimesController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin
	
	def create
		@time = PickupTime.new(pickup_time_params)
		if @time.save
			redirect_to pickup_locations_url
			flash[:success] = "New delivery time saved"
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
			redirect_to root_url
			flash[:error] = "Requested delivery time does not exist"
		end
	end

	def update
		@time = PickupTime.find(params[:id])
		if @time && @time.update_attributes(pickup_time_params)
			redirect_to pickup_locations_url
			flash[:success] = "Delivery time updated"
		else
			redirect_to edit_pickup_time_url(@time)
			flash[:error] = "Update failed. Please contact system admin."
		end
	end

	def destroy

	end

	private

	def pickup_time_params
		params.require(:pickup_time).permit(:pickup_hour, :pickup_minute, :cutoff_hour, :cutoff_minute)
	end
end
