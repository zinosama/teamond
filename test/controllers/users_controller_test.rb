require 'test_helper'

class UsersControllerTest < ActionController::TestCase

	def setup
		@admin = users(:zino)
		@non_admin = users(:ed)
	end

	test 'should get new' do
		get :new
		assert_response :success
		assert_select "title", full_title("Sign up")
	end

	test 'should redirect edit when not logged in' do
		get :edit, id: @admin
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect update when not logged in' do
		patch :update, id: @admin, user: { name: @admin.name, email: @admin.email }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect edit when logged in as wrong user' do
		log_in_as @non_admin
		get :edit, id: @admin
		assert_redirected_to menu_url
		assert_not flash.empty?
	end

	test 'should redirect update when logged in as wrong user' do
		log_in_as @non_admin
		patch :update, id: @admin, user: { name: @non_admin.name, email: @non_admin.email }
		assert_redirected_to menu_url
		assert_not flash.empty?
	end

	test 'should redirect index when not admin' do
		log_in_as @non_admin
		get :index
		assert_redirected_to menu_url
		assert_not flash.empty?
	end

	test 'should get index when logged in as admin' do
		log_in_as @admin
		get :index, admin_id: @admin.role.id
		assert_response :success
	end

	test 'should not allow admin attribute to be edited via web' do
		log_in_as @non_admin
		assert_not @non_admin.admin?
		patch :update, id: @non_admin, user: { password: 'password', password_confirmation: 'password', admin: true }
		assert_not @non_admin.admin?
	end
end
