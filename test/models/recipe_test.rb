require 'test_helper'

class RecipeTest < ActiveSupport::TestCase

	def setup
		@recipe = Recipe.new(name: "Fried Rice", description: "contains fish, chicken, and rice.", price: 12.11, image: "path_to_image", type: "Dish")
	end

	test 'should be valid' do
		assert @recipe.valid?
	end

end
