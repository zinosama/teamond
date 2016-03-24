require 'test_helper'

class PickupLocationsControllerTest < ActionController::TestCase

	def setup
		@location = pickup_locations(:one)
		@user = users(:ed)
	end

	test 'should redirect new when not logged in' do
		get :new
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect new when not logged in as admin' do
		log_in_as @user
		get :new
		assert_redirected_to root_url
		assert_not flash.empty?
	end
end
