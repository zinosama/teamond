require 'test_helper'

class PickupLocationsControllerTest < ActionController::TestCase

	def setup
		@user = users(:ed)
		@location = pickup_locations(:one)
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

	test 'should redirect show when not logged in' do
		get :show, id: @location
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect show when not logged in as admin' do
		log_in_as @user
		get :show, id: @location
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect edit when not logged in' do
		get :edit, id: @location
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect edit when not logged in as admin' do
		log_in_as @user
		get :edit, id: @location
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect update when not logged in' do
		patch :update, id: @location, pickup_location: { name: "hi", address: "address", description: "none" }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect update when not logged in as admin' do
		log_in_as @user
		patch :update, id: @location, pickup_location: { name: "hi", address: "address", description: "none" }
		assert_redirected_to root_url
		assert_not flash.empty?
	end
end
