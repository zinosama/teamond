require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
	
	def setup
		@user = users(:zino)
	end

	test 'unsuccessful edit' do
		log_in_as(@user)
		get edit_user_path @user.id
		assert_template 'users/edit'
		patch user_path(@user), user: { name: "ziiz", email: "foo@invaild", password: "s", password_confirmation: "djfs"}
		assert_template 'users/edit'
	end

	test 'successful edit with friendly forwarding' do
		get edit_user_path(@user)	
		log_in_as(@user)
		assert_redirected_to edit_user_path(@user)
		follow_redirect!
		assert_template 'users/edit'

		name = "foo"
		email = "foo@gmail.com"
		patch user_path(@user), user:{ name: name, email: email, password: "", password_confirmation: "" }
		assert_not flash.empty?
		assert_redirected_to @user
		@user.reload
		assert_equal name, @user.name
		assert_equal email, @user.email
	end
end
