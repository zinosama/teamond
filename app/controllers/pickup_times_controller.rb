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

	private

	def pickup_time_params
		params.require(:pickup_time).permit(:pickup_hour, :pickup_minute, :cutoff_hour, :cutoff_minute)
	end
end
