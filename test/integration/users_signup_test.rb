require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
	
	def setup
		ActionMailer::Base.deliveries.clear
	end

	test 'invalid signup information' do
		get signup_path
		assert_no_difference 'User.count' do 
			post users_path, user: { name: "", email: "invalidemail", password: "1111", password_confirmation: "111" }
		end
		assert_template 'users/new'
		assert_select 'li', count: 4
		assert_select 'div.ui.error.message', count: 1
	end

	test 'valid signup information with account activation' do
		get signup_path
		assert_difference 'User.count', 1 do 
			post users_path, user: { name: "gdragon", email: "gd@gmail.com", password: "dasdaa", password_confirmation: "dasdaa"}
		end
		assert_equal 1, ActionMailer::Base.deliveries.size
		user = assigns(:user)
		assert_not user.activated?
		assert_redirected_to root_url
		assert_not flash.empty?

		#try to login 
		log_in_as user
		assert_not is_logged_in?
		assert_not flash.empty?

		#invalid activation token
		get edit_account_activation_path("invalid token")
		assert_not is_logged_in?
		assert_not flash.empty?

		#valid activation token, wrong email
		get edit_account_activation_path(user.activation_token, email: 'wrong')
		assert_not is_logged_in?
		assert_not flash.empty?
		
		#valid activation token
		get edit_account_activation_path(user.activation_token, email: user.email)
		assert user.reload.activated?
		follow_redirect!
		assert_template 'static_pages/home'
		assert is_logged_in?
		assert_not flash.empty?
	end	
end
