require 'test_helper'

class OrdersControllerTest < ActionController::TestCase

	def setup 
		@user = users(:zino)
		@locations_time = locations_times(:one)
		@incorrect_user = users(:ed)
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

	test 'should redirect create if not logged in' do
		post :create, locations_time_id: @locations_time, order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 1 }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect create if cart is empty' do
		log_in_as @user
		post :create, locations_time_id: @locations_time, order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 1 }
		assert_redirected_to menu_url
		assert_not flash.empty?
	end

	test 'should redirect show if not logged in' do
		get :show, id: orders(:order1).id
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect show if not correct user' do
		log_in_as @incorrect_user
		get :show, id: orders(:order1).id
		assert_redirected_to root_url
		assert_not flash.empty?
	end
end
