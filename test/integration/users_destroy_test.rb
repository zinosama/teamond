require 'test_helper'

class UsersDestroyTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
		@other_user = users(:ed)
	end

	test 'should destroy when logged in as account owner' do
		log_in_as @other_user
		assert_difference "User.count", -1 do
			delete user_path(@other_user), confirm: "I Understand", password: 'password'
		end
		assert_redirected_to root_url
		follow_redirect!
		assert_not flash.empty?
		assert_not is_logged_in?
	end

	test 'should destroy when logged in as admin' do
		log_in_as @admin
		assert_difference "User.count", -1 do
			delete user_path(@other_user), confirm: "I Understand", password: 'password'
		end
		assert_redirected_to users_url
		follow_redirect!
		assert_not flash.empty?
		assert is_logged_in?	
	end

end
