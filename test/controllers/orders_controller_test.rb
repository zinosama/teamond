require 'test_helper'

class OrdersControllerTest < ActionController::TestCase

	def setup 
		@user = users(:zino)
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
		post :create, order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 1 }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect create if cart is empty' do
		log_in_as @user
		post :create, order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 1 }
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

	test 'should redirect update if not logged in' do
		patch :update, id: orders(:order1).id
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect update if not correct user' do
		log_in_as @incorrect_user
		patch :update, id: orders(:order1).id
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect index if not logged in' do
		get :index, user_id: @user.id
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirecet index if not correct users' do
		log_in_as @incorrect_user
		get :index, user_id: @user.id
		assert_redirected_to root_url
		assert_not flash.empty?
	end
end
