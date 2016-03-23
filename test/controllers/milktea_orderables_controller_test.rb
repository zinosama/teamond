require 'test_helper'

class MilkteaOrderablesControllerTest < ActionController::TestCase
	
	def setup
		@milktea = recipes(:milktea1)
		@user = users(:zino)
		@user2 = users(:ed)
		@milktea_orderable = milktea_orderables(:milktea_orderable1)
		@milktea_orderable.orderable = orderables(:orderable2)
	end

	test 'should redirect new when not logged in' do
		get :new, milktea_id: @milktea
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should get new when logged in' do
		log_in_as(@user)
		get :new, milktea_id: @milktea
		assert_response :success
		assert_select "title", full_title("Customize Milktea")
	end

	test 'should redirect create when not logged in' do
		post :create
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect edit when not logged in' do
		get :edit, id: @milktea_orderable
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect edit if user is not owner' do
		log_in_as(@user2)
		get :edit, id: @milktea_orderable
		assert_redirected_to cart_url
		assert_not flash.empty?
	end

	test 'should redirect update when not logged in' do 
		patch :update, id: @milktea_orderable
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect update if user is not owner' do
		log_in_as(@user2)
		patch :update, id: @milktea_orderable
		assert_redirected_to cart_url
		assert_not flash.empty?
	end

	# test 'should redirect destroy if not logged in' do
	# 	delete :destroy, id: @milktea_orderable
	# 	assert_redirected_to login_url
	# 	assert_not flash.empty?
	# end

	# test 'should redirect destroy if not owner' do
	# 	log_in_as(@user2)
	# 	delete :destroy, id: @milktea_orderable
	# 	assert_redirected_to cart_url
	# 	assert_not flash.empty?
	# end
end
