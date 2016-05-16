require 'test_helper'

class RecipeEditTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
		@shopper = users(:ed)

		@dish = recipes(:dish1)
		@dish_cate2 = dish_categories(:cate2)
		@milktea = recipes(:milktea1)

		@orderable = orderables(:one)
	end	

	test 'invalid recipe' do
		log_in_as @admin
		get manage_recipes_url
		patch recipe_path(@dish), recipe: { name: "", price: "", type: "", image: "", description: "", store_id: "" }
		assert_template 'recipes/edit'
		assert_select 'li', count: 7
		assert_select 'div.ui.error.message', count: 1
	end

	test 'valid dish' do
	
		valid_patch(@dish, "Milktea")
		#type cannot be changed
		assert_equal "Dish", @dish.type
		#dish_category can be changed if item is dish
		assert_equal @dish_cate2.id, @dish.dish_category_id

		#dish is active in menu management
		assert_select 'span.right.floated.success', text: "ACTIVE", count: 2

	end


test 'successful edit - milktea' do

		#orderables' status default to active
		assert @orderable.active?

		valid_patch(@milktea, "Dish")
		#type cannot be changed
		assert_equal "Milktea", @milktea.type
		#dish_category cannot be added if item is milktea
		assert_nil @milktea.dish_category_id

		#milktea is active in menu management
		assert_select 'span.right.floated.success', text: "ACTIVE", count: 2

	end

	private 

		def valid_patch(obj, asserted_type)
			log_in_as @admin
			get manage_recipes_url
			patch recipe_path(obj), recipe: { name: "edited", price: "100", type: asserted_type, dish_category_id: @dish_cate2.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
			assert_not flash[:success].empty?
			assert_redirected_to manage_recipes_url
			follow_redirect!

			correct_update_from_patch(obj)
		end

		def correct_update_from_patch(obj)
			obj.reload
			assert_equal "edited", obj.name
			assert_equal 100, obj.price
			assert_equal "edited", obj.description
			assert_match "salad.jpg", obj.image.model.image.file.file 
		end

end
