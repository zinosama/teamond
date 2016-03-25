require 'test_helper'

class PickupLocationsControllerTest < ActionController::TestCase

	def setup
		@user = users(:ed)
	end

	test 'should redirect index when not logged in' do
		get :index
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect index when not logged in as admin' do
		log_in_as @user
		get :index
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect create when not logged in' do
		post :create, pickup_location: { name: "...", address: "..."}
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect create when not logged in as admin' do 
		log_in_as @user
		post :create, pickup_location: { name: "...", address: "..." }
		assert_redirected_to root_url
		assert_not flash.empty?
	end
end
