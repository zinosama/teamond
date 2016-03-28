require 'test_helper'

class PickupTimeCreateTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
	end

	test 'valid pickup time' do
		log_in_as @user
		get pickup_locations_url
		assert_template "pickup_locations/index"

		assert_select "a", text: "Delivery Time - 18 : 20", count: 0

		assert_difference 'PickupTime.count', 1 do
			post pickup_times_url, pickup_time: { pickup_hour: 18, pickup_minute: 20, cutoff_hour: 17, cutoff_minute: 20 }
		end

		assert_redirected_to pickup_locations_url
		follow_redirect!
		assert_not flash.empty?

		assert_select "a", text: "Delivery Time - 18 : 20", count: 1
	end

	test 'invalid pickup time' do
		log_in_as @user
		assert_no_difference 'PickupTime.count' do
			post pickup_times_url, pickup_time: { pickup_hour: 120, pickup_minute: -1, cutoff_hour: "", cutoff_minute: "hi" }
		end
		assert_template 'pickup_locations/index'
	end
end
