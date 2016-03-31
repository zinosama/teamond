class Payment
	attr_reader :error_msg

	def initialize(payment_info)
		@payment_info = payment_info
	end

	def charge
		error_msg_body = "Ooops! Looks like our payment service is down. Please contact customer service and provide them with error message:"
		begin
			charge = Stripe::Charge.create(
				:amount => @payment_info[:total],
				:currency => @payment_info[:currency],
				:source => @payment_info[:source],
				:receipt_email => @payment_info[:receipt_email],
				:metadata => @payment_info[:metadata]
			)
		rescue Stripe::CardError => e
			body = e.json_body
			err = body[:error]
			@error_msg = err[:message]
		rescue Stripe::RateLimitError => e
			@error_msg = "Ooops! Something just went wrong. Please try again. If error persists, please contact customer service."
		rescue Stripe::InvalidRequestError => e
			@error_msg = "#{error_msg_body} Invalid Request."
		rescue Stripe::AuthenticationError => e
			@error_msg = "#{error_msg_body} Authentication Error."
		rescue Stripe::APIConnectionError => e
			@error_msg = "#{error_msg_body} Connection Error."
		rescue Stripe::StripeError => e
			@error_msg = "#{error_msg_body} Stripe Error."
		rescue => e
			@error_msg = "#{error_msg_body} Application Error"
		else
			@error_msg.empty? ? charge.id : false
		end
	end


end