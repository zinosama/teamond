require 'test_helper'

class OrderCreateTest < ActionDispatch::IntegrationTest
	using TimeRefinement
	DOWs = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	###!!! StripeMock requires Stripe gem version 1.31.0, which needs to be uncommented in Gemfile

	def setup
		@shopper = users(:shopper2)
		@dish_orderable = orderables(:two)
		@milktea_orderable = orderables(:three)
		@pickup_location = pickup_locations(:three)

		create_delivery_times(@pickup_location)

		StripeMock.start
		@token = StripeMock.generate_card_token(number: "4242424242424242", exp_month: 12, exp_year: 2017, cvc: '123')
	end

	def teardown
		StripeMock.stop
	end

	test 'valid order creation work flow (cash payment)' do
		log_in_as @shopper
		
		#############################Location##############
		get shopper_checkout_url(@shopper.role)
		assert_template 'orders/new'
		template = assigns(:template)
		assert_equal 'orders/checkout_templates/location_info', template

		#summary view is present, total is calculated correctly
		assert_select 'div.header', text: @dish_orderable.buyable.name.capitalize, count: 1
		assert_select 'div.header', text: @milktea_orderable.buyable.milktea.name.capitalize, count: 1
		assert_select 'p', text: "Quantity: #{@dish_orderable.quantity}"
		assert_select 'p', text: "Quantity: #{@milktea_orderable.quantity}"
		assert_select 'div.extra.content p', text: "Total Payment: $ #{(3.85*1.08).round(2)}", count: 1

		#location form and select field present
		assert_select 'form[action=?]', shopper_orders_url(@shopper.role), count: 1
		assert_select 'select[name=?]', "pickup_location_id", count: 1
		
		#only active pickup locations are selectable 
		assert_select 'option', count: 3
		assert_select 'option', text: "Select delivery location", count: 1
		assert_select 'option', text: @pickup_location.name, count: 1

		#orders create action correctly redirects
		post shopper_orders_url(@shopper.role), pickup_location_id: @pickup_location.id
		assert_redirected_to new_pickup_location_order_url(@pickup_location)
		follow_redirect!


		###############################LocationsTime###############
		template = assigns(:template)
		assert_equal 'orders/checkout_templates/time_info', template
		location = assigns(:pickup_location)
		assert_equal @pickup_location, location

		#time form and select field present
		assert_select 'form[action=?]', pickup_location_orders_url(@pickup_location), count: 1
		assert_select 'select[name=?]', "locations_time_id", count: 1

		#correct listing of selectable times
		assert_select 'option', count: 3
		assert_select 'option', text: "#{@before_cutoff.pickup_time}, #{DOWs[Time.now.strftime('%w').to_i]}"
		assert_select 'option', text: "#{@tomorrow.pickup_time}, #{DOWs[(Time.now.strftime('%w').to_i + 1) % 7]}"

		#orders create action correctly redirects
		post pickup_location_orders_url(@pickup_location), locations_time_id: @locations_time.id
		assert_redirected_to new_locations_time_order_url(@locations_time)
		follow_redirect!


		###############################RecipientInfo & Payment##########
		template = assigns(:template)
		assert_equal 'orders/checkout_templates/recipient_info', template
		locations_time = assigns(:locations_time)
		assert_equal @locations_time, locations_time

		assert_select 'form[action=?]', locations_time_orders_url(@locations_time), count: 1
		assert_select 'input[name=?]', 'order[recipient_name]', count: 1
		assert_select 'input[name=?]', 'order[recipient_phone]', count: 1
		assert_select 'input[name=?]', 'order[recipient_wechat]', count: 1
		assert_select 'select[name=?]', 'order[payment_method]', count: 1

		#an order is created
		assert_difference 'Order.count', 1 do
			post locations_time_orders_url(@locations_time), order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: "cash" }
		end
		order = assigns(:order)
		assert_redirected_to order_url(order)
		follow_redirect!
		assert_template 'orders/show'

		#order has correct information
		assert_equal "zino sama", order.recipient_name
		assert_equal "123456", order.recipient_phone
		assert_equal "abcdefg", order.recipient_wechat
		assert order.cash?
		assert_equal @locations_time.pickup_time_datetime, order.delivery_time
		assert_equal @shopper.role.id, order.shopper.id

		#orderables are reassigned to belong to the new order instead of user
		assert_equal order, @dish_orderable.reload.ownable
		assert_equal order, @milktea_orderable.reload.ownable

	end

	test 'valid order creation (online payment)' do
		log_in_as @shopper

		assert_difference 'Order.count', 1 do post_charge end

		order = assigns(:order)
		assert order.paid?
		assert_not_nil order.payment_id
		assert_redirected_to order_url(order)
	end

	test 'invalid online payment' do
		error_msg_body = "Ooops! Looks like our payment service is down. Please contact customer service and provide them with error message:"

		log_in_as @shopper

		StripeMock.prepare_card_error(:card_declined)
		assert_no_difference 'Order.count' do post_charge end
		verify_error 'orders/new', 'The card was declined'

		template = assigns(:template)
		assert_equal 'orders/checkout_templates/recipient_info', template
		locations_time = assigns(:locations_time)
		assert_equal @locations_time, locations_time

		post_charge_with_error Stripe::RateLimitError.new
		verify_error 'orders/new', 'Ooops! Something just went wrong. Please try again. If error persists, please contact customer service.'

		post_charge_with_error Stripe::InvalidRequestError.new('invalid request', { attr: 'invalid' })
		verify_error 'orders/new', "#{error_msg_body} Invalid Request."

		post_charge_with_error Stripe::AuthenticationError.new
		verify_error 'orders/new', "#{error_msg_body} Authentication Error."

		post_charge_with_error Stripe::APIConnectionError.new
		verify_error 'orders/new', "#{error_msg_body} Connection Error."

		post_charge_with_error Stripe::StripeError.new
		verify_error 'orders/new', "#{error_msg_body} Stripe Error."

		post_charge_with_error StandardError.new('application error')
		verify_error 'orders/new', "#{error_msg_body} Application Error."

	end

	test 'invalid recipient information' do
		log_in_as @shopper

		assert_no_difference 'Order.count' do
			post locations_time_orders_url(@locations_time), order: { recipient_name: "", recipient_phone: "", recipient_wechat: "" }
		end

		assert_template 'orders/new'
		template = assigns(:template)
		assert_equal 'orders/checkout_templates/recipient_info', template
		assert_select 'li', count: 4
		assert_select 'div.ui.error.message', count: 1
	end

	private 
	
	def verify_error(template, error_msg)
		assert_template template
		assert_equal error_msg, flash.now[:error]
	end

	def post_charge_with_error(error)
		StripeMock.prepare_error(error, :new_charge)
		assert_no_difference 'Order.count' do post_charge end
	end

	def post_charge
		post locations_time_orders_url(@locations_time), order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: "online" }, stripeToken: @token
	end

	#creates six scenarioes, each representing one of the possible cases. Two of them should be selectable.
	def create_delivery_times(location) 
		past_t 						=		Time.now - 1.day
		after_cutoff_t  	=		Time.now - 1.hour
		before_cutoff_t 	= 	Time.now + 1.hour
		tomorrow_t 				=	 	Time.now + 1.day
		after_tomorrow_t 	= 	Time.now + 2.day

		times = [ past_t, after_cutoff_t, before_cutoff_t, tomorrow_t, after_tomorrow_t ]
		
		pickup_times = times.map do |time|
			param = { cutoff_hour: time.get_hour, cutoff_minute: time.get_minute, pickup_hour: 23, pickup_minute: 59 }
			PickupTime.create! param
		end

		@before_cutoff = pickup_times[2]
		@tomorrow = pickup_times[3]

		pickup_times.each_with_index do |pickup_time, index|
			locations_time = location.locations_times.create!( pickup_time: pickup_time, day_of_week: times[index].get_dow )
			@locations_time = locations_time if index == 3	
		end

		location2 = pickup_locations(:two)
		location2.update_attribute(:active, true)
		location2.locations_times.create!( pickup_time: @tomorrow, day_of_week: times[3].get_dow )
	end
end
