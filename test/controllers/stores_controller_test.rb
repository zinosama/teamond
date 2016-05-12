require 'test_helper'

class StoresControllerTest < ActionController::TestCase

	def setup
		@admin = users(:zino)
		@shopper = users(:ed)
	end

	#New 
	test 'should get new' do
		log_in_as @admin
		get :new
		assert_response :success
		assert_selet "title", full_title("New Store")
	end

	test 'should redirect new if not logged in' do
		get :new
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect new if not admin' do
		log_in_as @shopper
		get :new
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end

	#Create
	test 'should redirect if not logged in' do
		post :create, store: {}
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect if not admin' do
		log_in_as @shopper
		post :create, store: {}
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end
 end
