require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
	
	def setup
		ActionMailer::Base.deliveries.clear
		@user = users(:zino)
	end

	test 'password resets' do
		get new_password_reset_path
		assert_template 'password_resets/new'

		#invalid email
		post password_resets_url, password_reset: { email: "invalid" }
		assert_template 'password_resets/new'
		assert_not flash.empty?
		
		#valid email
		post password_resets_url, password_reset: { email: @user.email }
		assert_not_equal @user.reset_digest, @user.reload.reset_digest
		assert_equal 1, ActionMailer::Base.deliveries.size
		assert_redirected_to root_url
		assert_not flash.empty?

		#password reset form
		user = assigns(:user)

		#wrong email
		get edit_password_reset_url(id: user.reset_token, email: "invalid email")
		assert_redirected_to root_url
		assert_not flash.empty?

		#inactive user
		user.update_attribute(:activated, false)
		get edit_password_reset_url(id: user.reset_token, email: user.email)
		assert_redirected_to root_url
		assert_not flash.empty?

		#right email, wrong token
		user.update_attribute(:activated, true)
		get edit_password_reset_url(id: "invalid_token", email: user.email)
		assert_redirected_to root_url
		assert_not flash.empty?

		#right email, right token
		get edit_password_reset_url(id: user.reset_token, email: user.email)
		assert_response :success
		assert_template 'password_resets/edit'
		assert_select "input[name=email][type=hidden][value=?]", user.email

		#invalid password & confirmation
		patch password_reset_url(id: user.reset_token), email: user.email, user: { password: "invalid", password_confirmation: "email" }
		assert_template 'password_resets/edit'
		assert_select 'div.error.message'

		#empty password
		patch password_reset_url(id: user.reset_token), email: user.email, user: { password: "", password_confirmation: "" }
		assert_template 'password_resets/edit'
		assert_select 'div.error.message'

		#valid password & confirmation
		patch password_reset_url(id: user.reset_token), email: user.email, user: { password: "dasdaaa", password_confirmation: "dasdaaa" }
		assert_redirected_to user
		assert_not flash.empty?
		assert is_logged_in?
	end

end
