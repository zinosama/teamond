require 'test_helper'

class RecipeShowTest < ActionDispatch::IntegrationTest

	def setup
		@recipe = recipes(:dish1)
	end

	test 'recipe show page' do
		get recipe_path(@recipe)
		assert_template 'recipes/show'
		assert_select 'h2', text: @recipe.name, count: 1
		assert_select 'p', text: "$ #{@recipe.price}", count: 1
	end
end
