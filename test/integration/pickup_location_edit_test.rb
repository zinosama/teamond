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
		
		#has green activate button
		assert_select 'input.ui.green.inverted.button[value=?]', "Activate This Location", count: 1
		assert_select 'input.ui.orange.inverted.button[value=?]', "Deactivate This Location", count: 0

		#edit content
		patch pickup_location_url(@location), pickup_location: { name: "new name", address: "new address", description: "new description" }
		assert_redirected_to pickup_location_url(@location)
		follow_redirect!
		assert_not flash.empty?

		assert_select 'p', text: "new address", count: 1
		assert_select 'p', text: "new description", count: 1

		#currently inactive
		assert_select 'p.ui.red.label', text: "Inactive", count: 1

		#edit to activate
		patch pickup_location_url(@location), active: "1"
		assert_redirected_to pickup_location_url(@location)
		follow_redirect!
		assert_not flash.empty?

		#currently active
		assert_select 'p.ui.green.label', text: "Active", count: 1

		#has orange deactivate button
		get edit_pickup_location_url(@location)
		assert_select 'input.ui.orange.inverted.button[value=?]', "Deactivate This Location", count: 1
		assert_select 'input.ui.green.inverted.button[value=?]', "Activate This Location", count: 0

		#edit to deactivate
		patch pickup_location_url(@location), active: "0", confirm_deactive: "i understand"
		assert_redirected_to pickup_location_url(@location)
		follow_redirect!
		assert_not flash.empty?

		#currently inactive
		assert_select 'p.ui.red.label', text: "Inactive", count: 1
	end

	test 'invalid update' do
		log_in_as @user
		patch pickup_location_url(@location), pickup_location: { name: "", address: "", description: "" }
		assert_template 'pickup_locations/edit'

		assert_select 'div.ui.error.message', count: 1
		assert_select 'li', count: 2
	end
end
