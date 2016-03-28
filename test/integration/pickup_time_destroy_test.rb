require 'test_helper'

class PickupTimeDestroyTest < ActionDispatch::IntegrationTest

	def setup 
		@user = users(:zino)
		@time = pickup_times(:one)
	end

	test 'should destroy pickup time record' do
		log_in_as @user

		#record appears on delivery management view
		get pickup_locations_url
		assert_select 'a.header', text: "Delivery Time - #{@time.pickup_time}", count: 1

		get edit_pickup_time_url(@time)
		assert_template 'pickup_times/edit'

		#delete without confirmation
		assert_no_difference 'PickupTime.count' do
			delete pickup_time_url(@time), id: @time
		end
		assert_redirected_to edit_pickup_time_url(@time)
		assert_not flash.empty?

		#delete with confirmation
		assert_difference 'PickupTime.count', -1 do
			delete pickup_time_url(@time), confirm_delete: "I Understand"
		end
		assert_redirected_to pickup_locations_url
		assert_not flash.empty?
		follow_redirect!

		#record no longer appears on delivery management view
		assert_select 'a.header', text: "Delivery Time - #{@time.pickup_time}", count: 0
	end

	test 'should destroy associated locations_time records' do
		log_in_as @user

		assert_difference 'LocationsTime.count', -1 do
			delete pickup_time_url(@time), confirm_delete: "I Understand"
		end
	end
	
end
