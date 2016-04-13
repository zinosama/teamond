require 'test_helper'

class DishCategoryCreateTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
	end

	test 'invalid dish category information' do
		log_in_as @user
		get manage_recipes_url
		assert_no_difference 'DishCategory.count' do
			post dish_categories_url, dish_category: { name: "" }
		end
		assert_template 'shared/manage'
		assert_select 'li', count: 1
		assert_select 'div.ui.error.message', count: 1
	end

	test 'valid dish category information' do
		log_in_as @user
		get manage_recipes_url
		
		#this category should always be there
		assert_select 'a.ui.tag.label', text: "Taichi Milktea", count: 1
		assert_select 'a.ui.tag.label', text: "valid_name", count: 0

		assert_difference 'DishCategory.count', 1 do
			post dish_categories_url, dish_category: { name: "valid_name" }
		end
		dish_category = assigns(:dish_category)
		
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash[:success].empty?
		assert_select 'a.ui.tag.label[href=?]', edit_dish_category_url(dish_category), text: "valid_name", count: 1
	end

end
