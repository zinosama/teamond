require 'test_helper'

class PickupLocationEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@location = pickup_locations(:one)
	end

	test 'valid update' do
		log_in_as @user
		get pickup_location_url(@location)
		assert_template 'pickup_locations/show'

		assert_select 'p', text: @location.address, count: 1
		assert_select 'p', text: @location.description, count: 1

		get edit_pickup_location_url(@location)
		assert_template 'pickup_locations/edit'

		patch pickup_location_url(@location), pickup_location: { name: "new name", address: "new address", description: "new description" }
		assert_redirected_to pickup_location_url(@location)
		follow_redirect!
		assert_not flash.empty?

		assert_select 'p', text: "new address", count: 1
		assert_select 'p', text: "new description", count: 1
	end

	test 'invalid update' do
		log_in_as @user
		patch pickup_location_url(@location), pickup_location: { name: "", address: "", description: "" }
		assert_template 'pickup_locations/edit'

		assert_select 'div.ui.error.message', count: 1
		assert_select 'li', count: 2
	end
end
