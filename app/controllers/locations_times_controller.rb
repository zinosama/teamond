class LocationsTimesController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin

	def create
		@location = PickupLocation.find(params[:pickup_location_id])
		days_of_week = params[:days_of_week] || []
		pickup_time_ids = params[:pickup_time_ids] || []
		create_delivery_times_for_location(@location, pickup_time_ids, days_of_week)
		flash[:success] = "Delivery Time Updated" if !days_of_week.empty? && !pickup_time_ids.empty?
		redirect_to pickup_location_url(@location)
	end

	def destroy
		locations_time = LocationsTime.find(params[:id])
		pickup_location = locations_time.pickup_location
		locations_time.destroy
		redirect_to pickup_location_url(pickup_location)
		flash[:success] = "Delivery time deleted"
	end

	private 

	def create_delivery_times_for_location(location, pickup_time_ids, days_of_week)
		days_of_week.each do |day_of_week|
			pickup_time_ids.each do |pickup_time_id|
				pickup_time = PickupTime.find(pickup_time_id)
				LocationsTime.find_or_create_by!( pickup_location: location, pickup_time: pickup_time, day_of_week: day_of_week)
			end
		end
	end

end
