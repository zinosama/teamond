require 'test_helper'

class OrdersControllerTest < ActionController::TestCase

	def setup 
		@admin = users(:zino)
		@shopper = users(:ed)
		@shopper2 = users(:shopper2)
	end

	test 'should redirect new if not logged in' do
		get :new, shopper_id: @shopper.id
		assert_redirected_to login_url
		assert_equal "Please log in first", flash[:error]
	end

	test 'should redirect new if not shopper' do
		log_in_as @admin
		get :new, shopper_id: @admin.id
		assert_redirected_to menu_url
		assert_equal "Access denied", flash[:error]
	end

	test 'should redirect new if cart is empty' do
		log_in_as @shopper2
		get :new, shopper_id: @shopper2.id
		assert_redirected_to menu_url
		assert_equal "Your cart is empty. Please add items before checkout.", flash[:error]
	end

	test 'should redirect create if not logged in' do
		post :create, shopper_id: @shopper.id, order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 1 }
		assert_redirected_to login_url
		assert_equal "Please log in first", flash[:error]
	end

	test 'should redirect create if not shopper' do
		log_in_as @admin
		post :create, shopper_id: @admin.id, order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 1 }
		assert_redirected_to menu_url
		assert_equal "Access denied", flash[:error]
	end

	test 'should redirect create if cart is empty' do
		log_in_as @shopper2
		post :create, shopper_id: @shopper2.id, order: { recipient_name: "zino sama", recipient_phone: "123456", recipient_wechat: "abcdefg", payment_method: 1 }
		assert_redirected_to menu_url
		assert_equal "Your cart is empty. Please add items before checkout.", flash[:error]
	end

	test 'should redirect show if not logged in' do
		get :show, id: orders(:order1).id
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect show if not correct user' do
		log_in_as @shopper2
		get :show, id: orders(:order1).id
		assert_redirected_to menu_url
		assert_not flash.empty?
	end

	test 'should redirect update if not logged in' do
		patch :update, id: orders(:order1).id
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect update if not correct user' do
		log_in_as @shopper2
		patch :update, id: orders(:order1).id
		assert_redirected_to menu_url
		assert_not flash.empty?
	end

	test 'should redirect index if not logged in' do
		get :index, shopper_id: @shopper.id
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirecet index if not correct users' do
		log_in_as @shopper2
		get :index, shopper_id: @shopper.id
		assert_redirected_to menu_url
		assert_not flash.empty?
	end
end
