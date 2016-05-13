require 'test_helper'

class RecipeCreateTest < ActionDispatch::IntegrationTest
	
	def setup
		@user = users(:zino)
		@store = stores(:one)
		@dish_category = dish_categories(:cate1)
	end

	test 'invalid recipe information' do
		log_in_as @user
		get manage_recipes_url
		assert_no_difference 'Recipe.count' do
			post recipes_path, recipe: { name: "", price: "", type: "", image: "", description: "", dish_category_id: "" }
		end
		assert_template 'shared/manage'
		assert_select 'li', count: 7
		assert_select 'div.ui.error.message', count: 1
	end

	test 'invalid dish_category_id' do
		log_in_as @user
		assert_no_difference 'Recipe.count' do
			post recipes_path, recipe: { name: "", price: "", type: "Dish", image: "", description: "", dish_category_id: "101" }
		end
		assert_template 'shared/manage'
		assert_not flash[:error].empty?
		assert_select 'li', count: 0
	end

	test 'valid recipe information - dish' do
		log_in_as @user
		assert_difference 'Dish.count', 1 do
			post recipes_path, recipe: { name: "dish-integrate", price: "1.23", type: "Dish", image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "description", dish_category_id: @dish_category.id, store_id: @store.id }
		end
		dish = assigns(:recipe)
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash[:success].empty?
		assert_select 'div.ui.error.message', count: 0
		assert_select 'div.header', text: "dish-integrate", count: 1
		assert_equal false, dish.active
	end

	test 'valid recipe information - milktea' do
		log_in_as @user
		assert_difference 'Milktea.count', 1 do
			post recipes_path, recipe: { name: "milktea1", price: "1.22", type: "Milktea", image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "description", store_id: @store.id }
		end
		milktea = assigns(:recipe)
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash[:success].empty?
		assert_select 'div.ui.error.message', count: 0
		assert_select 'p', text: 'milktea1', count: 0
		assert_equal false, milktea.active		
	end
end
