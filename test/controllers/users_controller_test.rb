require 'test_helper'

class UsersControllerTest < ActionController::TestCase

	def setup
		@user = users(:zino)
		@other_user = users(:ed)
	end

	test 'should get new' do
		get :new
		assert_response :success
		assert_select "title", full_title("Sign up")
	end

	test 'should redirect show when not logged in' do
		get :show, id: @user
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect edit when not logged in' do
		get :edit, id: @user
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect update when not logged in' do
		patch :update, id: @user, user: { name: @user.name, email: @user.email }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect show when logged in as wrong user' do
		log_in_as(@other_user)
		get :show, id: @user
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect edit when logged in as wrong user' do
		log_in_as(@other_user)
		get :edit, id: @user
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect update when logged in as wrong user' do
		log_in_as(@other_user)
		patch :update, id: @user, user: { name: @other_user.name, email: @other_user.email }
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect index when not admin' do
		log_in_as(@other_user)
		get :index
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should get index when logged in as admin' do
		log_in_as @user
		get :index
		assert_response :success
	end

	test 'should redirect leave when not logged in' do
		get :leave, id: @user
		assert_redirected_to login_url
	end

	test 'should redirect leave when logged in as wrong user' do
		log_in_as @other_user
		get :leave, id: @user
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should get leave when logged in as account owner' do
		log_in_as @other_user
		get :leave, id: @other_user
		assert_response :success
	end

	test 'should get leave when logged in as admin' do
		log_in_as @user
		get :leave, id: @other_user
		assert_response :success
	end

	test 'should redirect destroy when not logged in' do
		assert_no_difference 'User.count' do
			delete :destroy, id: @user
		end
		assert_redirected_to login_url
	end

	test 'should redirect destroy when logged in as wrong user' do
		log_in_as @other_user
		assert_no_difference 'User.count' do
			delete :destroy, id: @user
		end
		assert_redirected_to root_url
	end
end
