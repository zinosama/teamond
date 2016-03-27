require 'test_helper'

class LocationsTimeDestroyTest < ActionDispatch::IntegrationTest

	def setup
		@location = pickup_locations(:one)
		time = pickup_times(:one)
		@location_time = LocationsTime.create(pickup_location: @location, pickup_time: time, day_of_week: 1)

		@user = users(:zino)
	end

	test 'should destroy' do
		log_in_as @user
		assert_difference 'LocationsTime.count', -1 do
			delete locations_time_url(@location_time)
		end
		assert_redirected_to pickup_location_url(@location)
		follow_redirect!
		assert_not flash.empty?
	end
end
