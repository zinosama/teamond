require 'test_helper'

class RecipeDestroyTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@recipe = recipes(:dish1)
	end

	test 'should destroy' do 
		log_in_as @user
		get manage_recipes_url
		assert_difference 'Recipe.count', -1 do
			delete recipe_url(@recipe)
		end
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash.empty?
	end

end
