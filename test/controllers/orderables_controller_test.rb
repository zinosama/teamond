require 'test_helper'

class OrderablesControllerTest < ActionController::TestCase

	def setup
		@orderable = orderables(:one)
		@admin = users(:zino)
		@shopper = users(:ed)
		@shopper2 = users(:shopper2)
	end

	test 'should redirect index when not logged in' do
		get :index, shopper_id: @shopper
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end	

	test 'should redirect update when not logged in' do
		patch :update, id: @orderable, orderable: { quantity: 2 }
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect update if not owner' do
		log_in_as @shopper2
		patch :update, id: @orderable, orderable: { quantity: 2 }
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end

	test 'should redirect create when not logged in' do
		dish = recipes(:dish1)
		post :create, orderable: { buyable: dish, ownable: @shopper.role, quantity: 1, unit_price: 10 }, shopper_id: @shopper
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect create when not logged in as shopper' do
		log_in_as @admin
		dish = recipes(:dish1)
		post :create, orderable: { buyable: dish, ownable: @admin.role, quantity: 1, unit_price: 10 }, shopper_id: @shopper
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end

	test 'should redirect destroy when not logged in' do
		delete :destroy, id: @orderable
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect destroy if not owner' do
		log_in_as @shopper2
		delete :destroy, id: @orderable
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end
end
