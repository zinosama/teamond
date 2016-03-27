class PickupLocationsController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin

	def index
		@location = PickupLocation.new
		@locations = PickupLocation.all

		@time = PickupTime.new
		@times = PickupTime.all
	end

	def create
		@location = PickupLocation.new(pickup_location_params)
		if @location.save
			redirect_to pickup_locations_url
			flash[:success] = "New location saved."
		else
			@time = PickupTime.new
			@times = PickupTime.all
			@locations = PickupLocation.all
			render 'index'
		end
	end

	def show
		@day_of_week_namings = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		@location = PickupLocation.find(params[:id])
		locations_times = @location.locations_times
		
		@schedule = {}
		locations_times.each do |location_time|
			if @schedule[location_time.day_of_week]
				insert_by_pickup_time(@schedule[location_time.day_of_week], location_time.pickup_time)
			else
				@schedule[location_time.day_of_week] = [location_time.pickup_time]
			end
		end
		
	end

	private

	def pickup_location_params
		params.require(:pickup_location).permit(:name, :address, :description)
	end

	def insert_by_pickup_time(pickup_times, pickup_time)
		pickup_times.each_with_index do |time, index|
			if pickup_time.pickup_hour < time.pickup_hour
				pickup_times.insert(index, pickup_time)
				return
			elsif pickup_time.pickup_hour == time.pickup_hour && pickup_minute < time.pickup_minute
				pickup_times.insert(index, pickup_time)
				return
			end
		end
		pickup_times.push pickup_time
	end

end
