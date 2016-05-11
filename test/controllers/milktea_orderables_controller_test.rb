require 'test_helper'

class MilkteaOrderablesControllerTest < ActionController::TestCase
	
	def setup
		@milktea = recipes(:milktea1)
		@admin = users(:zino)
		@shopper = users(:ed)
		@shopper2 = users(:shopper2)
		@milktea_orderable = milktea_orderables(:milktea_orderable2)
	end

	test 'should redirect new when not logged in' do
		get :new, milktea_id: @milktea
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should get new when logged in as shopper' do
		log_in_as @shopper
		get :new, milktea_id: @milktea
		assert_response :success
		assert_select "title", full_title("Customize Milktea")
	end

	test 'should get redirected when not logged in as shopper' do
		log_in_as @admin
		get :new, milktea_id: @milktea
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end

	test 'should redirect create when not logged in' do
		post :create, shopper_id: @shopper
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect create when not logged in as shopper' do
		log_in_as @admin
		post :create, shopper_id: @shopper
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end

	test 'should redirect edit when not logged in' do
		get :edit, id: @milktea_orderable
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect edit if not owner' do
		log_in_as @shopper2
		get :edit, id: @milktea_orderable
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end

	test 'should redirect update when not logged in' do 
		patch :update, id: @milktea_orderable
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect update if not owner' do
		log_in_as @shopper2
		patch :update, id: @milktea_orderable
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end

end
