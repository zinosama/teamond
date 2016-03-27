require 'test_helper'

class LocationsTimesControllerTest < ActionController::TestCase

	def setup
		@user = users(:ed)
		@location = pickup_locations(:one)
		@time = pickup_times(:one)
	end

	test 'should redirect create when not logged in'  do
		post :create, pickup_location_id: @location, locations_time: { pickup_time: [ @time ], day_of_week: [1] }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect create when not logged in as admin' do
		log_in_as @user
		post :create, pickup_location_id: @location, locations_time: { pickup_time: [@time], day_of_week: [1] }
		assert_redirected_to root_url
		assert_not flash.empty?
	end

end
