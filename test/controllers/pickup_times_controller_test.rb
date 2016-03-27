require 'test_helper'

class PickupTimesControllerTest < ActionController::TestCase

	def setup 
		@user = users(:ed)
	end

	test 'should redirect create if not logged in' do
		post :create, pickup_time: { pickup_hour: 2, pickup_mintue: 20, cutoff_hour: 1, cutoff_minute: 20 }
		assert_redirected_to login_url
		assert_not flash.empty?
	end	

	test 'should redirect create if not logged in as admin' do
		log_in_as @user
		post :create, pickup_time: { pickup_hour: 2, pickup_mintue: 20, cutoff_hour: 1, cutoff_minute: 20 }
		assert_redirected_to root_url
		assert_not flash.empty?
	end
	
end
