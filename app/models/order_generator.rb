class OrderGenerator
	attr_reader :order, :cause_of_failure, :payment_error

	def initialize(order_params, locations_time, stripe_token, shopper)
		@order = Order.new(order_params)
		@shopper = shopper
		@locations_time = locations_time
		@stripe_token = stripe_token
		populate_order_attr
	end

	def place_order
		raise Exceptions::InvalidRecipientInfoError unless @order.valid?
		@order.paying_cash? ? @order.save :	process_online_payment
		reassign_orderables
		return true
	rescue Exceptions::InvalidRecipientInfoError
		@cause_of_failure = "invalid recipient info"
		return false		
	rescue Exceptions::OnlinePaymentError => e
		@cause_of_failure = "payment failure"
		@payment_error = e.message
		return false
	end

	private

		def populate_order_attr
			@order.total = @shopper.cart_balance_after_tax
			@order.shopper = @shopper
			@order.delivery_location = @locations_time.pickup_location.name
			@order.delivery_instruction = @locations_time.pickup_location.description
			@order.delivery_time = @locations_time.pickup_time_datetime
		end

		def reassign_orderables
			@shopper.orderables.update_all(ownable_id: @order.id, ownable_type: "Order")
		end

		def process_online_payment
			payment_info = {
				amount: (@order.total.to_f * 100).to_i,
				currency: "usd",
				source: @stripe_token,
				recipient_email: @shopper.email,
				metadata: { "order_id" => @order.id, "customer_name" => @shopper.name }
			}
			payment = Payment.new(payment_info)
			if charge = payment.charge
				@order.payment_id = charge.id
				@order.payment_status = 1
				@order.save
			else
				raise Exceptions::OnlinePaymentError, payment.error_msg
			end
		end
end