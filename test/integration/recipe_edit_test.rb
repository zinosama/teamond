require 'test_helper'

class RecipeEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@dish = recipes(:dish1)
		@milktea = recipes(:milktea1)
		@dish_cate2 = dish_categories(:cate2)
	end	

	test 'unsuccessful edit' do
		log_in_as @user
		get manage_recipes_url
		patch recipe_path(@dish), recipe: { name: "", price: "", type: "", image: "", description: "" }
		assert_template 'recipes/edit'
		assert_select 'li', count: 5
		assert_select 'div.ui.error.message', count: 1
	end

	test 'successful edit - dish' do
		log_in_as @user
		get manage_recipes_url
		patch recipe_path(@dish), recipe: { name: "edited", price: "100", type: "Milktea", dish_category_id: @dish_cate2.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		assert_not flash.empty?
		assert_redirected_to manage_recipes_url
		@dish.reload
		assert_equal "edited", @dish.name
		assert_equal 100, @dish.price
		assert_equal "edited", @dish.description
		assert_match "salad.jpg", @dish.image.model.image.file.file 

		#type cannot be changed
		assert_equal "Dish", @dish.type
		#dish_category can be changed if item is dish
		assert_equal @dish_cate2.id, @dish.dish_category_id

		#deactivate
		patch recipe_path(@dish), recipe: { active: "0" }
		assert_not flash[:success].empty?
		assert_redirected_to manage_recipes_url
		assert_equal false, @dish.reload.active

		#activate
		patch recipe_path(@dish), recipe: { active: "1" }
		assert_not flash[:success].empty?
		assert_redirected_to manage_recipes_url
		assert_equal true, @dish.reload.active
	end

	test 'successful edit - milktea' do
		log_in_as @user
		get manage_recipes_url
		patch recipe_path(@milktea), recipe: { name: "edited", price: "100", type: "Dish", dish_category_id: @dish_cate2.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		assert_not flash.empty?
		assert_redirected_to manage_recipes_url
		@milktea.reload
		assert_equal "edited", @milktea.name
		assert_equal	100, @milktea.price
		assert_equal "edited", @milktea.description
		assert_match "salad.jpg", @milktea.image.model.image.file.file

		#type cannot be changed
		assert_equal "Milktea", @milktea.type
		#dish_category cannot be added if item is milktea
		assert_nil @milktea.dish_category_id		
	end
end
