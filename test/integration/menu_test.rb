require 'test_helper'

class MenuTest < ActionDispatch::IntegrationTest

	test 'menu display' do
		get menu_url
		assert_template 'recipes/index'
		Recipe.all.each do |recipe|
			assert_select 'td', text: recipe.name, count: 1
			assert_select 'td', text: "$ #{recipe.price}", count: 1
			assert_select "a[href=?]", recipe_path(recipe), count: 1
		end
		DishCategory.all.each do |dish_category|
			assert_select 'th', text: dish_category.name, count: 1
		end
	end

end
