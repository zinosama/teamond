class Payment
	attr_reader :error_msg, :charge_obj

	def initialize(payment_info)
		@payment_info = payment_info
	end

	def charge
		error_msg_body = "Ooops! Looks like our payment service is down. Please contact customer service and provide them with error message:"
		begin
			# debugger
			@charge_obj = Stripe::Charge.create(
				:amount => @payment_info[:amount],
				:currency => @payment_info[:currency],
				:source => @payment_info[:source],
				:receipt_email => @payment_info[:receipt_email],
				:metadata => @payment_info[:metadata]
			)
		rescue Stripe::CardError => e
			body = e.json_body
			err = body[:error]
			@error_msg = err[:message]
			false
		rescue Stripe::RateLimitError => e
			@error_msg = "Ooops! Something just went wrong. Please try again. If error persists, please contact customer service."
			false
		rescue Stripe::InvalidRequestError => e
			@error_msg = "#{error_msg_body} Invalid Request."
			false
		rescue Stripe::AuthenticationError => e
			@error_msg = "#{error_msg_body} Authentication Error."
			false
		rescue Stripe::APIConnectionError => e
			@error_msg = "#{error_msg_body} Connection Error."
			false
		rescue Stripe::StripeError => e
			@error_msg = "#{error_msg_body} Stripe Error."
			false
		rescue => e
			@error_msg = "#{error_msg_body} Application Error"
			false
		else
			@charge_obj
		end
	end


end