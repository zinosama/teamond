class OrdersController < ApplicationController
	before_action :logged_in_user
	before_action :cart_not_empty, only: [:new, :create]
	before_action :correct_user_or_admin_order, only: [:show, :update]
	before_action :correct_user_index, only: [:index]

	def index
		@user = User.find(params[:user_id])
		if @user.admin?
			query_hash = {
				"unpaid" => {payment_status: 0},
				"unfulfilled" => {fulfillment_status: 0},
				"fulfilled" => {fulfillment_status: 1},
				"problemed" => {issue_status: [2, 3]},
				"feedbacked" => "issue IS NOT NULL"
			}
			@num_unpaid = Order.where(query_hash["unpaid"]).count
			@num_unfulfilled = Order.where(query_hash["unfulfilled"]).count
			@num_fulfilled = Order.where(query_hash["fulfilled"]).count
			@num_problem = Order.where(query_hash["problemed"]).count
			@num_feedback = Order.where(query_hash["feedbacked"]).count

			@orders = Order.where(query_hash[params[:query]])
			render('orders/index/admin') 
		else
			render('orders/index/user')
		end
	end

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
		@order = Order.find_by(id: params[:id])
		redirect_and_flash( user_url(current_user), :error, "Unidentified order" ) unless @order
	end 

	def update
		@order = Order.find_by(id: params[:id])
		
		if @order && params[:admin_form] && current_user.admin?
			@order.update_attributes( order_params_update_admin )
			redirect_and_flash(user_orders_url(current_user, query: params[:query]), :success, "Order updated")

		elsif @order && params[:admin_form].nil? && !current_user.admin?
			if @order.update_attributes( order_params_update_user )
				redirect_and_flash(order_url(@order), :success, "Thank you for your feedback")
			else
				flash.now[:error] = "Error. Please limit your feedback to under 255 characters."
				render 'show'
			end

		else
			redirect_and_flash(user_orders_url(current_user), :error, "Error. Unidentified order or unauthorized access" )
		end
	end


	private

	def order_params_update_user
		params.require(:order).permit(:satisfaction, :issue)
	end

	def order_params_update_admin
		params.require(:order).permit(:fulfillment_status, :solution, :note)
	end

	def order_params_create
		params.require(:order).permit(:payment_method, :recipient_name, :recipient_phone, :recipient_wechat)
	end

	def correct_user_index
		user = User.find_by(id: params[:user_id])
		if user
			redirect_and_flash(root_url, :error, "Unauthorized request") unless user == current_user
		else
			redirect_and_flash(root_url, :error, "Unidentified user")
		end
	end

	def correct_user_or_admin_order
		order = Order.find_by(id: params[:id])
		if order
			redirect_and_flash(root_url, :error, "Unauthorized request") unless ((order.user == current_user) || current_user.admin?)
		else
			redirect_and_flash(root_url, :error, "Unidentified order")
		end
	end

	def verify_info_and_create_order(locations_time, token)
		if locations_time
			@order = Order.new(order_params_create)
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
			redirect_and_flash( order_url(order), :success, "Your order has been successfully created." )
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
			redirect_and_flash( order_url(@order), :success, "Your order has been successfully created." )
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
