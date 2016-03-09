require 'test_helper'

class DishCategoryEditTest < ActionDispatch::IntegrationTest

	def setup
		@cate = dish_categories(:cate1)
		@user = users(:zino)
	end

	test 'unsuccessful edit' do 
		log_in_as @user
		get edit_dish_category_url(@cate)
		assert_template 'dish_categories/edit'
		patch dish_category_url(@cate), dish_category: { name: "", description: "a" * 256, image: fixture_file_upload('test/fixtures/images/too-large.jpg','images/jpeg') }
		assert_template 'dish_categories/edit'
		assert_select 'li', count: 3
		assert_select 'div.ui.error.message', count: 1		
	end

	test 'successful edit' do
		log_in_as @user
		get edit_dish_category_url(@cate)
		assert_template 'dish_categories/edit' 
		patch dish_category_url(@cate), dish_category: { name: "new-name", description: "valid description", image: fixture_file_upload('test/fixtures/images/salad.jpg', 'images/jpeg') }
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash.empty?
		assert_select 'a', text: 'new-name', count: 1
	end
end
