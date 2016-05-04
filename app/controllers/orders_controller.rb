class OrdersController < ApplicationController #this controller uses current_user. routes are not nested under shopper resource
	include ShopperValidations #contains valid_user
	before_action :logged_in_user
	before_action :valid_shopper, only: [:new, :create]
	before_action :valid_cart, only: [:new, :create]
	before_action :order_generation_router, only: [:new, :create]

	before_action :valid_order, only: [:show, :update]
	before_action :valid_shopper_or_admin, only: [:index]

	after_action :verify_authorized, only: [:show, :update]

	def index
		if @owner.is_a? Admin
			@num_unpaid = Order.where(Order.get_query("unpaid")).count
			@num_unfulfilled = Order.where(Order.get_query("unfulfilled")).count
			@num_fulfilled = Order.where(Order.get_query("fulfilled")).count
			@num_problem = Order.where(Order.get_query("complained")).count
			@num_feedback = Order.where(Order.get_query("resolved")).count

			@orders = Order.where(Order.get_query(params[:query])).order(created_at: :desc)
			render('orders/index/admin') 
		else
			@orders = @owner.orders.order(created_at: :desc)
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
		authorize @order
	end 

	def update
		authorize @order		
		@order.assign_attributes( order_update_params )
		@order.issue = params[:order][:issue] if @order.no_issue?
		@order.issue_status = 2 if params[:solved] == "1"
		raise Exceptions::InvalidOrderAttrsError unless @order.valid?
	rescue Exceptions::InvalidOrderAttrsError
		flash.now[:error] = "Error! Please limit your input to under 255 characters"
		render 'show'
	else
		@order.save
		admin_route = admin_orders_url(current_user.role, query: params[:query])
		shopper_route = order_url(@order)
		msg = "Updated successfully"
		redirect_and_flash( (current_user.admin? ? admin_route : shopper_route), :success, msg)
	end

	private
		
		def valid_shopper
			redirect_and_flash(menu_url, :error, "Access denied") unless current_user.shopper?
			@shopper = current_user.role
		end

		def valid_shopper_or_admin
			@owner = params[:shopper_id] ? Shopper.find(params[:shopper_id]) : Admin.find(params[:admin_id])
			redirect_and_flash(menu_url, :error, "Unauthorized access") unless current_user.role == @owner 
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Access denied")
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

 		def valid_order
			@order = Order.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(shopper_orders_url(current_user.role), :error, "Invalid request")
 		end

 		def order_update_params
 			params.require(:order).permit(policy(@order).permitted_update_attributes)
 		end

		def order_create_params
			params.require(:order).permit(policy(Order).permitted_create_attributes)
		end

end