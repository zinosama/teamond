require 'test_helper'

class MilkteaAddonsControllerTest < ActionController::TestCase

	def setup
		@user = users(:ed)
		@addon = milktea_addons(:bubble)
	end

	test 'should redirect create when not logged in' do
		post :create
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect create when not logged in as admin' do
		log_in_as(@user)
		post :create
		assert_redirected_to root_url
		assert_not flash[:error].empty?
	end
	
	test 'should redirect edit when not logged in' do
		get :edit, id: @addon
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end	

	test 'should redirect edit when not logged in as admin' do
		log_in_as(@user)
		get :edit, id: @addon
		assert_redirected_to root_url
		assert_not flash[:error].empty?
	end

	test 'should redirect update when not logged in' do
		patch :update, id: @addon, milktae_addon: { name: "new name", price: 0.3 }
		assert_redirected_to login_url
		assert_not flash[:error].empty?
	end

	test 'should redirect update when not logged in as admin' do
		log_in_as(@user)
		patch :update, id: @addon, milktae_addon: { name: "new name", price: 0.3 }
		assert_redirected_to root_url
		assert_not flash[:error].empty?
	end

end
