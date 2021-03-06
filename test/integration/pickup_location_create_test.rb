require 'test_helper'

class PickupLocationCreateTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
	end

	test 'valid pickup location' do
		log_in_as @user
		get pickup_locations_url
		assert_template 'pickup_locations/index'

		#empty listing before create
		assert_select 'a', text: "its", count: 0

		assert_difference 'PickupLocation.count', 1 do
			post pickup_locations_url, pickup_location: { name: "its", address: "500 joseph", description: "over here" }
		end
		assert_redirected_to pickup_locations_url
		follow_redirect!
		assert_not flash.empty?

		#listing contains the new record
		assert_select 'a', text: "its", count: 1

	end

	test 'invalid pickup location' do
		log_in_as @user
		assert_no_difference 'PickupLocation.count' do
			post pickup_locations_url, pickup_location: { name: "", address: "" }
		end
		assert_template 'pickup_locations/index'
		assert_select 'li', count: 2
		assert_select 'div.ui.error.message', count: 1
	end
end
