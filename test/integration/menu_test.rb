require 'test_helper'

class MenuTest < ActionDispatch::IntegrationTest

	test 'menu display' do
		get menu_url
		assert_template 'recipes/index'
		Recipe.all.each do |recipe|
			assert_select 'p', text: recipe.name
			assert_select 'p', text: recipe.price
			assert_select "a[href=?]", recipe_path(recipe)
		end
		DishCategory.all.each do |dish_category|
			assert_select 'h2', text: dish_category.name
		end
	end

end
