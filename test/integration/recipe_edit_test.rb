require 'test_helper'

class RecipeEditTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)

		@dish = recipes(:dish1)
		@dish_cate = dish_categories(:cate1)
		@milktea = recipes(:milktea1)
	end	

	test 'invalid update' do
		log_in_as @admin
		get manage_recipes_url
		patch recipe_path(@dish), recipe: { name: "", price: "", type: "", image: "", description: "", store_id: "" }
		assert_template 'recipes/edit'
		assert_select 'li', count: 9
		assert_select 'div.ui.error.message', count: 1
	end

	test 'type cannot be changed' do
		log_in_as @admin
		patch recipe_path(@dish), recipe: { name: "edited", price: 100, type: "Milktea", dish_category_id: @dish_cate.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		recipe = assigns(:recipe)
		recipe.errors.full_messages.include? "Type cannot be changed"
		assert_template 'recipes/edit'
		assert_select 'li', count: 1
		assert_select 'div.ui.error.message', count: 1
	end

	test 'milktea cannot have dish category' do
		log_in_as @admin
		patch recipe_path(@milktea), recipe: { name: "edited", price: 100, type: "Milktea", dish_category_id: @dish_cate.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		recipe = assigns(:recipe)
		assert recipe.errors.full_messages.include? "Dish category must be blank"
		assert_template 'recipes/edit'
	end
	
	test 'valid dish update' do
		log_in_as @admin
		patch recipe_path(@dish), recipe: { name: "edited", price: 100, type: "Dish", dish_category_id: @dish_cate.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		@dish.reload
		assert_equal "edited", @dish.name
		assert_equal 100, @dish.price
		assert_equal "edited", @dish.description
		assert_redirected_to manage_recipes_url
		assert_not flash[:success].empty?
	end
	
	test 'valid milktea update' do
		log_in_as @admin
		patch recipe_path(@milktea), recipe: { name: "edited", price: 100, type: "Milktea", image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		@milktea.reload
		assert_equal "edited", @milktea.name
		assert_equal 100, @milktea.price
		assert_equal "edited", @milktea.description
		assert_redirected_to manage_recipes_url
		assert_not flash[:success].empty?
	end

end
