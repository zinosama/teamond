require 'test_helper'

class LocationsTimeCreateTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@location = pickup_locations(:one)
		@time = pickup_times(:one)
	end

	test 'valid locations_time' do
		log_in_as @user
		get pickup_location_url(@location)
		assert_template 'pickup_locations/show'

		assert_select 'a.ui.label', text: @time.pickup_time, count: 0

		assert_difference 'LocationsTime.count', 2 do
			post pickup_location_locations_times_url(@location), pickup_time_ids: [ @time.id ], days_of_week: [ 0, 6 ]
		end
		assert_redirected_to pickup_location_url(@location)
		follow_redirect!
		assert_not flash.empty?

		assert_select 'a.ui.label', text: @time.pickup_time, count: 2

		#does not generate repeat record
		assert_no_difference 'LocationsTime.count' do
			post pickup_location_locations_times_url(@location), pickup_time_ids: [ @time.id ], days_of_week: [ 0, 6 ]
		end
		assert_redirected_to pickup_location_url(@location)
		follow_redirect!
		assert_not flash.empty?
	end

end
