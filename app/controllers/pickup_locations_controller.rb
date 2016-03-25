class PickupLocationsController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin

	def index
		@location = PickupLocation.new
		@locations = PickupLocation.all
	end

	def create
		@location = PickupLocation.new(pickup_location_params)
		if @location.save
			redirect_to pickup_locations_url
			flash[:success] = "New location saved."
		else
			@locations = PickupLocation.all
			render 'index'
		end
	end

	private

	def pickup_location_params
		params.require(:pickup_location).permit(:name, :address, :description)
	end
end
