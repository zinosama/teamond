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

		assert_no_difference 'PickupLocation.count' do
			delete pickup_location_url(@location)
		end
		assert_redirected_to edit_pickup_location_url(@location)
		assert_not flash.empty?

		assert_difference 'PickupLocation.count', -1 do
			delete pickup_location_url(@location), confirm_delete: 'I Understand'
		end
		assert_redirected_to pickup_locations_url
		follow_redirect!
		assert_not flash.empty?

		assert_select 'a.header', text: @location.name, count: 0
	end

	test 'should destroy locations_time record' do
		log_in_as @user
		assert_difference 'LocationsTime.count', -1 do
			delete pickup_location_url(@location), confirm_delete: 'I Understand'
		end
		assert_redirected_to pickup_locations_url
	end
end
