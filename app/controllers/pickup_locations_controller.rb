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
				insert_by_pickup_time(@schedule[location_time.day_of_week], location_time)
			else
				@schedule[location_time.day_of_week] = [location_time]
			end
		end
	end

	def edit
		@location = PickupLocation.find(params[:id])
	end

	def update
		@location = PickupLocation.find(params[:id])
		if @location.update_attributes(pickup_location_params)
			redirect_to pickup_location_url(@location)
			flash[:success] = "Location updated"
		else
			render 'pickup_locations/edit'
		end
	end

	private

	def pickup_location_params
		params.require(:pickup_location).permit(:name, :address, :description)
	end

	def insert_by_pickup_time(location_times, new_location_time)
		new_pickup_time = new_location_time.pickup_time
		location_times.each_with_index do |location_time, index|
			pickup_time = location_time.pickup_time
			
			if new_pickup_time.pickup_hour < pickup_time.pickup_hour
				location_times.insert(index, new_location_time)
				return
			elsif new_pickup_time.pickup_hour == pickup_time.pickup_hour && new_pickup_time.pickup_minute < pickup_time.pickup_minute
				location_times.insert(index, new_location_time)
				return
			end
		end
		location_times.push new_location_time
	end

end
