require 'test_helper'

class RecipeEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@dish = recipes(:dish1)
	end	

	test 'unsuccessful edit' do
		log_in_as @user
		get manage_recipes_url
		patch recipe_path(@dish), recipe: { name: "", price: "", type: "", image: "", description: "" }
		assert_template 'recipes/edit'
		assert_select 'li', count: 5
		assert_select 'div.ui.error.message', count: 1
	end

	test 'successful edit' do
		log_in_as @user
		get manage_recipes_url
		patch recipe_path(@dish), recipe: { name: "edited", price: "100", type: "Milktea", image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		assert_not flash.empty?
		assert_redirected_to manage_recipes_url
		@dish.reload
		assert_equal "edited", @dish.name
		assert_equal 100, @dish.price
		assert_equal "Dish", @dish.type
		assert_equal "edited", @dish.description
		assert_match "salad.jpg", @dish.image.model.image.file.file 
	end
end
