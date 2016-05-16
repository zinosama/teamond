require 'test_helper'

class RecipeCreateTest < ActionDispatch::IntegrationTest
	
	def setup
		@admin = users(:zino)
		@store = stores(:one)
		@dish_category = dish_categories(:cate1)
	end

	test 'Dish requires dish category' do
		log_in_as @admin
		post recipes_path, recipe: { name: "valid", price: 12, type: "Dish", image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "valid", store_id: @store.id }
		recipe = assigns(:recipe)
		assert_equal 1, recipe.errors.full_messages.size
		assert_equal "Dish category can't be blank", recipe.errors.full_messages[0]
	end

	test 'Dish rejects invalid dish_category_id' do
		log_in_as @admin
		assert_no_difference 'Recipe.count' do
			post recipes_path, recipe: { name: "valid", price: 12, type: "Dish", image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "valid", dish_category_id: 101, store_id: @store.id }
		end
		recipe = assigns(:recipe)
		assert recipe.errors.full_messages.include? "Dish category can't be blank"
	end

	test 'Milktea does not require dish category' do
		log_in_as @admin
		post recipes_path, recipe: { name: "valid", price: 12, type: "Milktea", image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "valid", store_id: @store.id }
		assert_redirected_to manage_recipes_url
		assert_not flash[:success].empty?
	end
	
	test 'recipe without type is invalid' do
		log_in_as @admin
		post recipes_path, recipe: { name: "valid", price: 12, image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "valid", store_id: @store.id }
		recipe = assigns(:recipe)
		assert_equal 2, recipe.errors.full_messages.size
		assert recipe.errors.full_messages.include? "Type can't be blank"
	end
	
	test 'recipe rejects invalid type' do
		log_in_as @admin
		assert_raises(ActiveRecord::SubclassNotFound) do 
			post recipes_path, recipe: { name: "valid", price: 12, type: "milktea", image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "valid", store_id: @store.id }
		end
	end
	
	test 'invalid recipe information' do
		log_in_as @admin
		assert_no_difference 'Recipe.count' do
			post recipes_path, recipe: { name: "", price: "", type: "", image: "", description: "", dish_category_id: "" }
		end
		recipe = assigns(:recipe)
		assert_select 'li', count: 8
		assert_select 'div.ui.error.message', count: 1
	end

	test 'valid recipe information - dish' do
		log_in_as @admin
		assert_difference 'Dish.count', 1 do
			post recipes_path, recipe: { name: "dish-integrate", price: "1.23", type: "Dish", image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "description", dish_category_id: @dish_category.id, store_id: @store.id }
		end
		dish = assigns(:recipe)
		assert_not dish.active?
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash[:success].empty?
		assert_select 'div.header', text: "dish-integrate", count: 1
	end

	test 'valid recipe information - milktea' do
		log_in_as @admin
		assert_difference 'Milktea.count', 1 do
			post recipes_path, recipe: { name: "milktea1", price: "1.22", type: "Milktea", image: fixture_file_upload('test/fixtures/images/salad2.jpg','images/jpeg'), description: "description", store_id: @store.id }
		end
		milktea = assigns(:recipe)
		assert_not milktea.active?		
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash[:success].empty?
		assert_select 'p', text: 'milktea1', count: 0
	end
end
