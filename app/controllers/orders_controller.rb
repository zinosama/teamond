class OrdersController < ApplicationController #this controller uses current_user. routes are not nested under shopper resource
	include ShopperValidations #contains valid_user
	before_action :logged_in_user
	before_action :valid_shopper, only: [:new, :create]
	before_action :valid_cart, only: [:new, :create]
	before_action :order_generation_router, only: [:new, :create]


	# before_action :correct_user_or_admin_order, only: [:show, :update]
	# before_action :correct_user_index, only: [:index]

	def index
		@user = User.find(params[:user_id])
		if @user.admin?
			query_hash = {
				"unpaid" => {payment_status: 0},
				"unfulfilled" => {fulfillment_status: 0},
				"fulfilled" => {fulfillment_status: 1},
				"complained" => {issue_status: [1, 2]},
				"resolved" => {issue_status: 3}
			}
			@num_unpaid = Order.where(query_hash["unpaid"]).count
			@num_unfulfilled = Order.where(query_hash["unfulfilled"]).count
			@num_fulfilled = Order.where(query_hash["fulfilled"]).count
			@num_problem = Order.where(query_hash["complained"]).count
			@num_feedback = Order.where(query_hash["resolved"]).count

			@orders = Order.where(query_hash[params[:query]]).order(created_at: :desc)
			render('orders/index/admin') 
		else
			@orders = @user.orders.order(created_at: :desc)
			render('orders/index/user')
		end
	end

	def new
		case @instruction
		when "pickup_location needed"
			@template = 'orders/checkout_templates/location_info'
		when "locations_time needed"
			@template = 'orders/checkout_templates/time_info'
		when "recipient info needed"
			@order = Order.new(recipient_name: @shopper.name, recipient_phone: @shopper.phone, recipient_wechat: @shopper.wechat)
			@template = 'orders/checkout_templates/recipient_info'
		end
	end

	def create
		case @instruction
		when "ready to place order"
			order_generator = OrderGenerator.new(order_params_create, @locations_time, params[:stripeToken], @shopper)
			if order_generator.place_order
				redirect_to order_url(order_generator.order)
			else
				@template = "orders/checkout_templates/recipient_info"
				flash.now[:error] = order_generator.payment_error if order_generator.cause_of_failure == "payment failure"
				@order = order_generator.order if order_generator.cause_of_failure == "invalid recipient info"
				render "new"
			end
		when "locations_time posted"
			redirect_to new_locations_time_order_url(@locations_time)
		when "pickup_location posted"
			redirect_to new_pickup_location_order_url(@pickup_location)
		end
	end

	def show 
		@order = Order.find_by(id: params[:id])
		redirect_and_flash( user_orders_url(current_user), :error, "Unidentified order" ) unless @order
	end 

	def update
		@order = Order.find_by(id: params[:id])
		
		if @order && params[:admin_form] && current_user.admin?
			@order.update_attributes( order_params_update_admin )
			@order.update_attribute( :issue_status, 2 ) if params[:order][:issue_status] == "2" && @order.issue_status == 1
			@order.update_attribute( :issue_status, 1 ) if params[:order][:issue_status] == "100" && @order.issue_status == 2
			redirect_and_flash(user_orders_url(current_user, query: params[:query]), :success, "Order updated")

		elsif @order && params[:admin_form].nil? && !current_user.admin?
			
			if @order.issue_status == 0
				if @order.update_attributes( order_params_update_user )
					@order.update_attribute(:issue_status, 1) if @order.issue && !@order.issue.empty?
					redirect_and_flash(order_url(@order), :success, "Thank you for your feedback")
				else
					flash.now[:error] = "Error. Please limit your feedback to under 255 characters."
					render 'show'
				end
			elsif @order.issue_status == 3
				@order.update_attribute(:satisfaction, params[:order][:satisfaction])
				redirect_and_flash(order_url(@order), :success, "Thank you for your feedback")
			else
				@order.update_attribute( :issue_status, 3) if !params[:solved].nil? && params[:solved] == "1"
				redirect_and_flash(order_url(@order), :success, "Thank you for your update")
			end

		else
			redirect_and_flash(user_orders_url(current_user), :error, "Error. Unidentified order or unauthorized access" )
		end
	end


	private
		
		def valid_shopper
			redirect_and_flash(menu_url, :error, "Access denied") unless current_user.shopper?
			@shopper = current_user.role
		end

		def order_generation_router
			if params[:order]
				@instruction = "ready to place order"
			elsif params[:locations_time_id]
				@instruction = request.get? ? "recipient info needed" : "locations_time posted"
				@locations_time = LocationsTime.find(params[:locations_time_id])
				raise Exceptions::InactiveDeliveryLocationError unless @locations_time.pickup_location.active?
			elsif params[:pickup_location_id]
				@instruction = request.get? ? "locations_time needed" : "pickup_location posted"
				@pickup_location = PickupLocation.find(params[:pickup_location_id])
				raise Exceptions::InactiveDeliveryLocationError unless @pickup_location.active?
			else
				@instruction = "pickup_location needed"
			end	
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(shopper_checkout_url(@shopper), :error, "Invalid delivery location or time")
		rescue Exceptions::InactiveDeliveryLocationError
			redirect_and_flash(shopper_checkout_url(@shopper), :error, "Inactive delivery location")
		end

		def valid_cart
			if @shopper.item_count == 0
				redirect_and_flash(menu_url, :error, "Your cart is empty. Please add items before checkout.")
			elsif @shopper.invalid_orderables?
				redirect_and_flash(shopper_cart_url(@shopper), :error, "Please remove unavailable or verify changed items before checkout")
			end
		end
		# def order_params_update_user
		# 	params.require(:order).permit(:satisfaction, :issue)
		# end

		# def order_params_update_admin
		# 	params.require(:order).permit(:fulfillment_status, :solution, :note, :payment_status)
		# end

		# def order_params_create
		# 	params.require(:order).permit(:payment_method, :recipient_name, :recipient_phone, :recipient_wechat)
		# end

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

end
