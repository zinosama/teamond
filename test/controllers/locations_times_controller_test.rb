require 'test_helper'

class LocationsTimesControllerTest < ActionController::TestCase

	def setup
		# @record = LocationsTime.new( pickup_location: pickup_locations(:one), pickup_time: pickup_times(:one), day_of_week: 1)
		@user = users(:ed)
	end

	test 'should redirect create when not logged in'  do
		post :create, locations_time: { pickup_location: pickup_locations(:one), pickup_time: pickup_times(:one), day_of_week: 1 }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect create when not logged in as admin' do
		log_in_as @user
		post :create, locations_time: { pickup_location: pickup_locations(:one), pickup_time: pickup_times(:one), day_of_week: 1 }
		assert_redirected_to root_url
		assert_not flash.empty?
	end

end
