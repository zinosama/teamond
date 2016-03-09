require 'test_helper'

class DishCategoryDestroyTest < ActionDispatch::IntegrationTest

	def setup
		@cate = dish_categories(:cate1)
		@user = users(:zino)
	end

	test 'should destroy' do 
		log_in_as @user
		get manage_recipes_url
		assert_difference 'DishCategory.count', -1 do
			delete dish_category_url(@cate)
		end
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_not flash.empty?
		assert_select 'a', text: 'cate1', count: 0		
	end

end
