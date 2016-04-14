require 'test_helper'

class DishCategoryIndexTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
	end

	test 'should list all categories in manage' do
		log_in_as @admin
		get manage_recipes_url

		DishCategory.all.each do |category|
			if category.active
				assert_select 'a.ui.orange.tag.label[href=?]', edit_dish_category_url(category), text: category.name, count: 1
			else
				assert_select 'a.ui.red.tag.label[href=?]', edit_dish_category_url(category), text: category.name, count: 1
			end
		end
	end

	test 'should list only active categories in dish select' do
		log_in_as @admin
		get manage_recipes_url
		
		DishCategory.all.each do |category|
			if category.active
				assert_select 'option', text: category.name, count: 1
			else
				assert_select 'option', text: category.name, count: 0
			end
		end
	end

end
