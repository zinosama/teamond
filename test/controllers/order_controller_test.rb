require 'test_helper'

class OrderControllerTest < ActionController::TestCase

	def setup 
		@user = users(:zino)
	end

	test 'should redirect new if not logged in' do
		get :new
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should get new' do
		log_in_as @user
		get :new
		assert_response :success
		assert_template 'orders/new'
	end
end
