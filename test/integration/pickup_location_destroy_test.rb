require 'test_helper'

class PickupLocationDestroyTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@location = pickup_locations(:one)
	end

	test 'should destroy location record' do
		log_in_as @user
		get edit_pickup_location_url(@location)
		assert_template 'pickup_locations/edit'

		assert_select 'input.ui.red.inverted.button[value=?]', "DELETE This Location", count: 1

		assert_difference 'PickupLocation.count', -1 do
			delete pickup_location_url(@location)
		end

		assert_redirected_to pickup_locations_url
		follow_redirect!
		assert_not flash.empty?

		assert_select 'a.header', text: @location.name, count: 0
	end
end
