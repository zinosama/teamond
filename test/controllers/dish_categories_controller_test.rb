require 'test_helper'

class DishCategoriesControllerTest < ActionController::TestCase
	
	def setup
		@user = users(:ed)
		@dish_cate = dish_categories(:cate1)
	end	

	test 'should redirect create when not logged in' do
		assert_no_difference 'DishCategory.count' do
			post :create, dish_category: { name: "new-cate" }
		end	
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect create when logged in as non-admin' do
		log_in_as @user
		assert_no_difference 'DishCategory.count' do
			post :create, dish_category: { name: "new-cate" }
		end	
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect edit when not logged in' do
		get :edit, id: @dish_cate
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect edit when logged in as non-admin' do
		log_in_as @user
		get :edit, id: @dish_cate
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect update when not logged in' do
		patch :update, id: @dish_cate, dish_category: { name: "edited cate" }
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect update when logged in as non-admin' do
		log_in_as @user
		patch :update, id: @dish_cate, dish_category: { name: "edited cate" }
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect delete when not logged in' do
		delete :destroy, id: @dish_cate
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect delete when logged in as non-admin' do
		delete :destroy, id: @dish_cate
		assert_redirected_to login_url
		assert_not flash.empty?
	end
end
	