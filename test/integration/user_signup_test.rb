require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
	
	test 'invalid signup information' do
		get signup_path
		assert_no_difference 'User.count' do 
			post users_path, user: { name: "", email: "invalidemail", password: "1111", password_confirmation: "111" }
		end
		assert_template 'users/new'
		assert_select 'li', count: 4
		assert_select 'div.ui.error.message', count: 1
	end

	test 'valid signup information' do
		get signup_path
		assert_difference 'User.count', 1 do 
			post_via_redirect users_path, user: { name: "gdragon", email: "gd@gmail.com", password: "dasdaa", password_confirmation: "dasdaa"}
		end
		assert_template 'users/show'
		assert_not flash.empty?
	end	
end
