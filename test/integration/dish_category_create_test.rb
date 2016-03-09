require 'test_helper'

class DishCategoryCreateTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
	end

	test 'invalid dish category information' do
		log_in_as @user
		get manage_recipes_url
		assert_no_difference 'DishCategory.count' do
			post dish_categories_url, dish_category: { name: "", description: "a" * 256, image: fixture_file_upload('test/fixtures/images/too-large.jpg','images/jpeg') }
		end
		assert_template 'shared/manage'
		assert_select 'li', count: 3
		assert_select 'div.ui.error.message', count: 1
	end

	test 'valid dish category information' do
		log_in_as @user
		get manage_recipes_url
		assert_difference 'DishCategory.count', 1 do
			post dish_categories_url, dish_category: { name: "valid_name", image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg') }
		end
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_select 'div.ui.error.message', count: 0
		assert_select 'a', text: 'valid_name', count: 1
	end

end
