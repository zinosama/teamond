require 'test_helper'

class OrdersControllerTest < ActionController::TestCase

	def setup 
		@user = users(:zino)
	end

	test 'should redirect new if not logged in' do
		get :new
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect new if cart is empty' do
		log_in_as @user
		get :new
		assert_redirected_to menu_url
		assert_not flash.empty?
	end
end
