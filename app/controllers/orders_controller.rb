class OrdersController < ApplicationController
	before_action :logged_in_user
	before_action :cart_not_empty, only: [:new, :create]
	include OrderablesHelper

	def new
		if request.url == summary_url
			@template = 'location_info'
		elsif params[:pickup_location_id]
			@location = PickupLocation.find(params[:pickup_location_id])
			@template = 'time_info'
		elsif params[:locations_time_id]
			@order = Order.new(recipient_name: current_user.name, recipient_phone: current_user.phone, recipient_wechat: current_user.wechat)
			@locations_time = LocationsTime.find(params[:locations_time_id])
			@template = 'recipient_info'
		end
	end

	def create
		if request.url == orders_url #coming from summary_url
			if PickupLocation.find_by(id: params[:pickup_location_id])
				redirect_to new_pickup_location_order_url(pickup_location_id: params[:pickup_location_id])
			else
				redirect_and_flash(summary_url, :error, "Unidentified location")
			end
		elsif params[:locations_time_id] && params[:order] #coming from new_locations_time_order_url
			@locations_time = LocationsTime.find_by(id: params[:locations_time_id])
			@template = 'recipient_info'

			if @locations_time
				total = (sum(current_user.orderables) * 1.08).round(2) * 100
				@order = Order.new(order_params)
				if @order.update_attributes(total: total, user_id: current_user.id, locations_time_id: @locations_time.id )
					@order.payment_method == 1 ? redirect_to(order_url(@order)) : process_online_payment(@order, params[:stripeToken])
				else
					render 'new'
				end
			else
				redirect_and_flash( new_locations_time_order_url(@locations_time), :error, "Unidentified time and location")
			end

		elsif params[:locations_time_id] #coming from new_pickup_location_order_url
			locations_time = LocationsTime.find(params[:locations_time_id])
			if locations_time
				redirect_to new_locations_time_order_url(locations_time)
			else
				redirect_and_flash(new_pickup_location_order_url(pickup_location_id: params[:pickup_location_id]), :error, "Unidentified delivery time")
			end
		end 
	end

	def show 
		@order = Order.find(params[:id])
	end 

	private

	def process_online_payment(order, token)
		begin
			Stripe.api_key = ENV["STRIPE_TEST_SECRET_KEY"]
			charge = charge_card( order.total, token, current_user.email, order.id )
		rescue Stripe::CardError => e
			flash.now[:error] = e.message
			render 'new'
		else
			@order.update_attributes( payment_id: charge.id )
			redirect_to order_url(@order)
		end
	end

	def charge_card(total, token, email, order_id)
		charge = Stripe::Charge.create(
			:amount => total.to_i,
			:currency => "usd",
			:source => token,
			:receipt_email => email,
			:metadata => { "order_id" => order_id, "customer_name" => current_user.name }
		)
	end

	def order_params
		params.require(:order).permit(:payment_method, :recipient_name, :recipient_phone, :recipient_wechat)
	end

	def cart_not_empty
		if current_user.orderables.empty?
			redirect_to menu_url
			flash[:error] = "Your cart is empty. Please add items before check out."
		end
	end


end
