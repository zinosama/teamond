require 'test_helper'

class DishCategoryEditTest < ActionDispatch::IntegrationTest

	def setup
		@cate = dish_categories(:cate1)
		@dish = @cate.dishes.first
		@user = users(:zino)
	end

	test 'invalid dish category' do 
		log_in_as @user
		get edit_dish_category_url(@cate)
		assert_template 'dish_categories/edit'
		patch dish_category_url(@cate), dish_category: { name: "" }
		assert_template 'dish_categories/edit'
		assert_select 'li', count: 1
		assert_select 'div.ui.error.message', count: 1		
	end

	test 'valid dish category' do
		log_in_as @user
		
		assert_equal true, @dish.active

		get edit_dish_category_url(@cate)
		assert_template 'dish_categories/edit' 
		assert_select 'input.ui.inverted.red.button.deleteButton[value=?]', 'Disable Category', count: 1

		patch dish_category_url(@cate), dish_category: { active: "0" }
		dish_category = assigns(:dish_category)
		assert_equal false, dish_category.active
		assert_equal false, @dish.reload.active

		assert_redirected_to manage_recipes_url
		assert_not flash[:success].empty?
		follow_redirect!

		assert_select 'a.ui.red.label.tag[href=?]', edit_dish_category_url(@cate), count: 1 
		patch dish_category_url(@cate), dish_category: { active: "1" }
		dish_category = assigns(:dish_category)
		assert_equal true, dish_category.active
		assert_equal false, @dish.reload.active

		assert_redirected_to manage_recipes_url
		assert_not flash[:success].empty?
		follow_redirect!
		assert_select 'a.ui.orange.label.tag[href=?]', edit_dish_category_url(@cate), count: 1

		patch dish_category_url(@cate), dish_category: { name: "new-name" }
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash[:success].empty?
		assert_select 'a.ui.orange.label.tag[href=?]', edit_dish_category_url(@cate), text: 'new-name', count: 1
	end
end
