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
				location_time.join_by_pickup_time(@schedule[location_time.day_of_week])
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
		if params[:active]
			params[:active] == "0" ? update_active(false, @location) : update_active(true, @location)
		else
			@location.update_attributes(pickup_location_params) ? redirect_and_flash(pickup_location_url(@location), :success, "Location updated") : render('pickup_locations/edit')
		end
	end

	def destroy
		location = PickupLocation.find(params[:id])
		if user_confirmed? params[:confirm_delete]
			location.destroy
			redirect_and_flash(pickup_locations_url, :success, "Location has been removed")
		else
			redirect_and_flash(edit_pickup_location_url(location), :error, "Please type I Understand to confirm delete!")
		end
	end

	private

	def update_active(activating, location)
		if activating
			location.update_attribute(:active, true)
			redirect_and_flash(pickup_location_url(location), :success, "Location is now active")
		elsif user_confirmed? params[:confirm_deactive]
			location.update_attribute(:active, false)
			redirect_and_flash(pickup_location_url(location), :info, "Location has been deactived")
		else
			redirect_and_flash(edit_pickup_location_url(location), :error, "Deactivation failed! Please type in 'I Understand' and try again!")
		end
	end

	def pickup_location_params
		params.require(:pickup_location).permit(:name, :address, :description)
	end

end
