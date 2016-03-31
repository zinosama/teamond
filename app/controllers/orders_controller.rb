class OrdersController < ApplicationController
	before_action :logged_in_user
	before_action :cart_not_empty, only: [:new, :create]
	include OrderablesHelper

	def new
		if request.url == summary_url
			@template = 'orders/checkout_templates/location_info'
		elsif params[:pickup_location_id]
			@location = PickupLocation.find(params[:pickup_location_id])
			@template = 'orders/checkout_templates/time_info'
		elsif params[:locations_time_id]
			@order = Order.new(recipient_name: current_user.name, recipient_phone: current_user.phone, recipient_wechat: current_user.wechat)
			@locations_time = LocationsTime.find(params[:locations_time_id])
			@template = 'orders/checkout_templates/recipient_info'
		end
	end

	def create
		if got_location?(request.url)
			
			location_id = params[:pickup_location_id]
			route_params = {
				object: PickupLocation.find_by(id: location_id),
				from_url: summary_url,
				to_url: new_pickup_location_order_url(location_id),
				error_msg: "Unidentified location"
			}
			verify_and_redirect(route_params)

		elsif got_all_info?(params[:locations_time_id], params[:order])

			@locations_time = LocationsTime.find_by(id: params[:locations_time_id])
			@template = 'orders/checkout_templates/recipient_info'
			verify_info_and_create_order(@locations_time, params[:stripeToken])

		elsif got_time?(params[:locations_time_id])

			association_id = params[:locations_time_id]
			route_params = {
				object: LocationsTime.find_by(id: association_id),
				from_url: new_pickup_location_order_url(association_id),
				to_url: new_locations_time_order_url(association_id),
				error_msg: "Unidentified delivery time"
			}
			verify_and_redirect(route_params)
		
		end 
	end

	def show 
		@order = Order.find(params[:id])
	end 


	private

	
	def order_params
		params.require(:order).permit(:payment_method, :recipient_name, :recipient_phone, :recipient_wechat)
	end

	def verify_info_and_create_order(locations_time, token)
		if locations_time
			@order = Order.new(order_params)
			if @order.update_attributes(total: current_user.cart_balance_after_tax, user_id: current_user.id, locations_time_id: locations_time.id )
				process_payment(@order, token)
			else
				render 'new'
			end
		else
			redirect_and_flash( new_locations_time_order_url(locations_time), :error, "Unidentified time and location")
		end
	end

	def verify_and_redirect(args)
		if args[:object]
			redirect_to args[:to_url]
		else
			redirect_and_flash(args[:from_url], :error, args[:error_msg])
		end
	end

	def got_location?(incoming_url)
		incoming_url == orders_url
	end

	def got_time?(time_info)
		time_info
	end

	def got_all_info?(locations_time, order_info)
		locations_time && order_info
	end

	def reassign_orderables(order)
		current_user.orderables.update_all(ownable_id: order.id, ownable_type: "Order")
	end

	def process_payment(order, token)
		if order.paying_cash?
			reassign_orderables(order)
			redirect_to order_url(order) 
		else
			process_online_payment(order, token)
		end
	end

	def process_online_payment(order, token)
		payment_info = {
			amount: (order.total * 100).to_i,
			currency: "usd",
			source: token,
			receipt_email: current_user.email,
			metadata: { "order_id" => order.id, "customer_name" => current_user.name }
		}
		payment = Payment.new(payment_info)

		if charge = payment.charge
			@order.update_attributes( payment_id: charge.id, payment_status: 1 )
			reassign_orderables(@order)
			redirect_to order_url(@order)
		else
			flash.now[:error] = payment.error_msg
			@order = destroy_and_recreate(@order)
			render 'orders/new'
		end
	end

	def destroy_and_recreate(order)
		new_order = Order.new( recipient_name: order.recipient_name, recipient_phone: order.recipient_phone, recipient_wechat: order.recipient_wechat)
		order.destroy
		new_order
	end	

	def cart_not_empty
		if current_user.orderables.empty?
			redirect_to menu_url
			flash[:error] = "Your cart is empty. Please add items before check out."
		end
	end


end
