require 'test_helper'

class PickupTimeEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@time = pickup_times(:one)
	end

	test 'valid pickup time' do
		log_in_as @user

		#record appears on delivery management view
		get pickup_locations_url
		assert_select 'a.header', text: "Delivery Time - #{@time.pickup_time}", count: 1
		assert_select 'div.description', text: "Order cutoff time - #{@time.cutoff_time}", count: 1

		get edit_pickup_time_url(@time)
		assert_template 'pickup_times/edit'

		patch pickup_time_url(@time), pickup_time: { pickup_hour: 10, pickup_minute: 12, cutoff_hour: 9, cutoff_minute: 13 }
		assert_redirected_to pickup_locations_url
		assert_not flash.empty?
		follow_redirect!

		#updated records appear on delivery management view
		assert_select 'div.description', text: "Order cutoff time - 09 : 13", count: 1
		assert_select 'a.header', text: "Delivery Time - 10 : 12", count: 1
	end

	test 'invalid pickup time' do
		log_in_as @user

		#record appears on delivery management view
		get pickup_locations_url
		assert_select 'a.header', text: "Delivery Time - #{@time.pickup_time}", count: 1
		assert_select 'div.description', text: "Order cutoff time - #{@time.cutoff_time}", count: 1

		patch pickup_time_url(@time), pickup_time: { pickup_hour: "", pickup_minute: 800, cutoff_hour: 123, cutoff_minute: "hi"  }
		assert_redirected_to edit_pickup_time_url
		assert_not flash.empty?
		
		#record unchanged
		get pickup_locations_url
		assert_select 'a.header', text: "Delivery Time - #{@time.pickup_time}", count: 1
		assert_select 'div.description', text: "Order cutoff time - #{@time.cutoff_time}", count: 1
	end
end
