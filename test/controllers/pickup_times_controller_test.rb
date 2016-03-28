require 'test_helper'

class PickupTimesControllerTest < ActionController::TestCase

	def setup 
		@user = users(:ed)
		@time = pickup_times(:one)
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

	test 'should redirect edit if not logged in' do
		get :edit, id: @time
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect edit if not logged in as admin' do
		log_in_as @user
		get :edit, id: @time
		assert_redirected_to root_url
		assert_not flash.empty?
	end
	
	test 'should update if not logged in' do
		patch :update, id: @time
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should update if not logged in as admin' do
		log_in_as @user
		patch :update, id: @time
		assert_redirected_to root_url
		assert_not flash.empty?
	end

end
