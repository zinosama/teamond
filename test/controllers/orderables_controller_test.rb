require 'test_helper'

class OrderablesControllerTest < ActionController::TestCase

	def setup
		@orderable1 = orderables(:orderable1)
		@user = users(:zino)
		@user2 = users(:ed)
	end

	test 'should redirect index when not logged in' do
		get :index
		assert_redirected_to login_url
		assert_not flash.empty?
	end	

	test 'should redirect update when not logged in' do
		patch :update, id: @orderable1, orderable: { quantity: 2 }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect update if not owner' do
		log_in_as @user
		patch :update, id: @orderable1, orderable: { quantity: 2 }
		assert_redirected_to cart_url
		assert_not flash.empty?
	end

	test 'should redirect create when not logged in' do
		dish = recipes(:dish1)
		post :create, orderable: { buyable: dish, ownable: @user, quantity: 1, unit_price: 10 }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect destroy when not logged in' do
		delete :destroy, id: @orderable1
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect destroy if not owner' do
		log_in_as(@user2)
		delete :destroy, id: @orderable1
		assert_redirected_to cart_url
		assert_not flash.empty?
	end
end
