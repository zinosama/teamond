class OrdersController < ApplicationController
	before_action :logged_in_user
	before_action :cart_not_empty, only: [:new, :create]

	def new
		if request.url == summary_url
			@template = 'location_info'
		elsif params[:pickup_location_id]
			@location = PickupLocation.find(params[:pickup_location_id])
			@template = 'time_info'
		elsif params[:locations_time_id]
			@order = Order.new
			@locations_time = LocationsTime.find(params[:locations_time_id])
			@template = 'recipient_info'
		end
	end

	def create
		if request.url == orders_url
			if PickupLocation.find_by(id: params[:pickup_location_id])
				redirect_to new_pickup_location_order_url(pickup_location_id: params[:pickup_location_id])
			else
				redirect_and_flash(summary_url, :error, "Unidentified location")
			end
		elsif params[:locations_time_id]
			location_time = LocationsTime.find(params[:locations_time_id])
			if location_time
				redirect_to new_locations_time_order_url(location_time)
			else
				redirect_and_flash(new_pickup_location_order_url(pickup_location_id: params[:pickup_location_id]), :error, "Unidentified delivery time")
			end
		end 
	end

	private

	def cart_not_empty
		if current_user.orderables.empty?
			redirect_to menu_url
			flash[:error] = "Your cart is empty. Please add items before check out."
		end
	end


end
