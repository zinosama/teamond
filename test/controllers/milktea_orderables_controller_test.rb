require 'test_helper'

class MilkteaOrderablesControllerTest < ActionController::TestCase
	
	def setup
		@milktea = recipes(:milktea1)
		@user = users(:zino)
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
end
