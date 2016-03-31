require 'test_helper'

class OrderCreateTest < ActionDispatch::IntegrationTest
	DOWs = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

	def setup
		@user = users(:zino)

		@dish_orderable = orderables(:orderable1)
		@dish_orderable.buyable = recipes(:dish1)

		@milktea_orderable = orderables(:orderable2)
		@milktea_orderable.buyable = milktea_orderables(:milktea_orderable1)
		
		@location = pickup_locations(:one)
		@location.update_attribute(:active, true)
		@locations_time = locations_times(:one)

		@user.orderables = [@dish_orderable, @milktea_orderable]
		@user.save

		StripeMock.start
	end

	def teardown
		StripeMock.stop
	end

	test 'valid order with cash payment' do
		log_in_as @user
		get summary_url
		assert_template 'orders/new'

		#summary view is present, total is calculated correctly
		assert_select 'div.header', text: @dish_orderable.buyable.name.capitalize, count: 1
		assert_select 'div.header', text: @milktea_orderable.buyable.milktea.name.capitalize, count: 1
		assert_select 'p', text: "Quantity: #{@dish_orderable.quantity}"
		assert_select 'p', text: "Quantity: #{@milktea_orderable.quantity}"
		assert_select 'div.extra.content p', text: "Total Payment: $ #{(4.4*1.08).round(2)}", count: 1

		#location form and select field present
		assert_select 'form[action=?]', orders_url, count: 1
		assert_select 'select[name=?]', "pickup_location_id", count: 1
		
		#only active pickup locations are selectable 
		assert_select 'option', count: 2
		assert_select 'option', text: "Select delivery location", count: 1
		assert_select 'option', text: @location.name, count: 1

		create_delivery_times(@location)

		#orders create action correctly redirects
		post orders_url, pickup_location_id: @location.id
		assert_redirected_to new_pickup_location_order_url(@location)
		follow_redirect!

		#time form and select field present
		assert_select 'form[action=?]', pickup_location_orders_url(@location), count: 1
		assert_select 'select[name=?]', "locations_time_id", count: 1

		#correct listing of selectable times
		assert_select 'option', count: 3
		assert_select 'option', text: "#{@today_before_cutoff.pickup_time} - #{DOWs[Time.now.strftime('%w').to_i]}"
		assert_select 'option', text: "#{@tomorrow.pickup_time} - #{DOWs[(Time.now.strftime('%w').to_i + 1) % 7]}"

		#orders create action correctly redirects
		post pickup_location_orders_url(@location), locations_time_id: @locations_time.id
		assert_redirected_to new_locations_time_order_url(@locations_time)
		follow_redirect!
		assert_select 'form[action=?]', locations_time_orders_url(@locations_time), count: 1
		assert_select 'input[name=?]', 'order[recipient_name]', count: 1
		assert_select 'input[name=?]', 'order[recipient_phone]', count: 1
		assert_select 'input[name=?]', 'order[recipient_wechat]', count: 1
		assert_select 'select[name=?]', 'order[payment_method]', count: 1

		#an order is created
		assert_difference 'Order.count', 1 do
			post locations_time_orders_url(@locations_time), order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 1 }
		end
		order = assigns(:order)
		assert_redirected_to order_url(order)
		follow_redirect!
		assert_template 'orders/show'

		#order has correct information
		assert_equal "zino sama", order.recipient_name
		assert_equal "123456", order.recipient_phone
		assert_equal "abcdefg", order.recipient_wechat
		assert_equal 1, order.payment_method
		assert_equal @locations_time.id, order.locations_time.id
		assert_equal @user.id, order.user.id

		#orderables are reassigned to belong to the new order instead of user
		assert_equal order, @dish_orderable.reload.ownable
		assert_equal order, @milktea_orderable.reload.ownable

	end

	test 'valid order with online payment' do
		log_in_as @user

		token = StripeMock.generate_card_token(number: "4242424242424242", exp_month: 12, exp_year: 2017, cvc: '123')

		assert_difference 'Order.count', 1 do
			post locations_time_orders_url(@locations_time), order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 0, }, stripeToken: token
		end
		order = assigns(:order)
		assert_equal 1, order.payment_status
		assert_not_nil order.payment_id
		assert_redirected_to order_url(order)
	end


		# StripeMock.prepare_card_error(:card_declined)
	private 
	
	#creates six scenarioes, each representing one of the possible cases. Two of them should be selectable.
	def create_delivery_times(location) 
		now = Time.now
		current_hr = now.strftime('%k').to_i
		current_min = now.strftime('%M').to_i
		current_day = now.strftime('%w').to_i

		past = PickupTime.create!( pickup_hour: current_hr - 1, pickup_minute: current_min, cutoff_hour: current_hr - 2, cutoff_minute: current_min )
		location.locations_times.create!( pickup_time: past, day_of_week: current_day )

		today_after_cutoff = PickupTime.create!( pickup_hour: current_hr + 1, pickup_minute: current_min, cutoff_hour: current_hr - 1, cutoff_minute: current_min)
		location.locations_times.create!( pickup_time: today_after_cutoff, day_of_week: current_day )

		@today_before_cutoff = PickupTime.create!( pickup_hour: current_hr + 2, pickup_minute: current_min, cutoff_hour: current_hr + 1, cutoff_minute: current_min)
		location.locations_times.create!( pickup_time: @today_before_cutoff, day_of_week: current_day )

		@tomorrow = PickupTime.create!( pickup_hour: current_hr + 1, pickup_minute: current_min, cutoff_hour: current_hr - 1, cutoff_minute: current_min)
		location.locations_times.create!( pickup_time: @tomorrow, day_of_week: ((current_day + 1) % 7) )

		day_after_tomorrow = PickupTime.create!( pickup_hour: current_hr + 2, pickup_minute: current_min, cutoff_hour: current_hr + 2, cutoff_minute: current_min)
		location.locations_times.create!( pickup_time: day_after_tomorrow, day_of_week: ((current_day + 2) % 7) )
	
		location2 = pickup_locations(:two)
		location2.update_attribute(:active, true)
		location2.locations_times.create!( pickup_time: @tomorrow, day_of_week: ((current_day + 1) % 7) )
	end
end
