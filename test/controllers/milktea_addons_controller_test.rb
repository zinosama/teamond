require 'test_helper'

class MilkteaAddonsControllerTest < ActionController::TestCase

	test 'should redirect create when not logged in' do
		post :create
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect create when not logged in as admin' do
		user = users(:ed)
		log_in_as(user)
		post :create
		assert_redirected_to root_url
		assert_not flash.empty?
	end
	
end
