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

	test 'shopper cannot visit signup' do
		shopper = users(:ed)
		log_in_as shopper
		#get signup
		get signup_path
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
		#post users_path
		assert_no_difference 'User.count' do
			post users_path, user: { name: "valid", email: "valid@gmail.com", password: "dasdaa", password_confirmation: "dasdaa" }
		end
		assert_redirected_to menu_url
		assert_not flash[:error].empty? 
	end

	test 'only admin creates non-shopper user' do
		#guest
		get signup_path
		assert_select 'select[name=?]', 'user[role_type]', count: 0
		assert_select 'select[name=?]', 'user[role_attributes][store_id]', count: 0
		
		assert_difference 'User.count', 1 do
			post users_path, user: { name: "name", email: "email@gmail.com", password:"dasdaa", password_confirmation: "dasdaa", role_type: "Driver", role_attributes: { store_id: "" } }
		end
		user = assigns(:user)
		assert user.shopper?
		
		#shopper cannot create new user, per the above test
		
		#admin
		admin = users(:zino)
		store = stores(:one)
		log_in_as admin
		
		get signup_path
		assert_select 'select[name=?]', 'user[role_type]', count: 1
		assert_select 'select[name=?]', 'user[role_attributes][store_id]', count: 1
		
		assert_difference 'User.count', 1 do 
			post users_path, user: { name: "name", email: "emailadmincreatesnonshopper-user@gmail.com", password: "dasdaa", password_confirmation: "dasdaa", role_type: "Provider", role_attributes: { store_id: store.id } }
		end	
		provider = assigns(:user)
		assert provider.provider?
		assert_equal store, provider.role.store
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
