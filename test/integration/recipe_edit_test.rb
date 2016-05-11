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
		patch recipe_path(@dish), recipe: { name: "", price: "", type: "", image: "", description: "" }
		assert_template 'recipes/edit'
		assert_select 'li', count: 5
		assert_select 'div.ui.error.message', count: 1
	end

	test 'valid dish' do
		
		#associate dish with two orderables
		orderable_one = Orderable.create!(buyable: @dish, ownable: @shopper.role, unit_price: @dish.price)
		orderable_two = Orderable.create!(buyable: @dish, ownable: shoppers(:shopper_two), unit_price: @dish.price)
		assert_equal 2, @dish.orderables.size
		#orderables' status default to 0
		assert_equal 0, orderable_one.status
		assert_equal 0, orderable_two.status

		valid_patch(@dish, "Milktea")
		#type cannot be changed
		assert_equal "Dish", @dish.type
		#dish_category can be changed if item is dish
		assert_equal @dish_cate2.id, @dish.dish_category_id
		#patch changes orderables' status to 1
		assert_equal 1, orderable_one.reload.status
		assert_equal 1, orderable_two.reload.status

		#dish is active in menu management
		assert_select 'span.right.floated.success', text: "ACTIVE", count: 2

		#login as shopper, check cart, and see warning msgs
		cart_after_patch(@dish)
		
		#login admin and deactivate recipe
		deactivate_recipe(@dish)

		#associated orderables' status change as well
		assert_equal 2, orderable_one.reload.status
		assert_equal 2, orderable_two.reload.status
		
		#check cart again
		cart_after_deactivate

		#should not be able to checkout
		checkout

		#activate
		activate_recipe(@dish)

		#check cart again
		cart_after_activate

		#should not be able to checkout
		checkout

		#click on link to change orderable status from 1 to 0
		confirm_changes(orderable_one)
	end


test 'successful edit - milktea' do

		#orderables' status default to 0
		assert_equal 0, @orderable.status

		valid_patch(@milktea, "Dish")
		#type cannot be changed
		assert_equal "Milktea", @milktea.type
		#dish_category cannot be added if item is milktea
		assert_nil @milktea.dish_category_id
		#patch changes orderable status to 1
		assert_equal 1, @orderable.reload.status

		#milktea is active in menu management
		assert_select 'span.right.floated.success', text: "ACTIVE", count: 2

		#login as shopper, check cart, and see warning msgs
		cart_after_patch(@milktea)
		
		#login admin and deactivate recipe
		deactivate_recipe(@milktea)

		#deactivation changes orderable status to 2
		assert_equal 2, @orderable.reload.status

		#check cart again
		cart_after_deactivate

		#should not be able to checkout
		checkout

		#activate
		activate_recipe(@milktea)

		#check cart again
		cart_after_activate

		#should not be able to checkout
		checkout

		#click on link to change orderable status from 1 to 0
		confirm_changes(@orderable)	
	end

	private 

		def checkout
			get shopper_checkout_url(@shopper.role)
			assert_redirected_to shopper_cart_url(@shopper.role)
			assert_equal "Please remove unavailable or verify changed items before checkout", flash[:error]
			follow_redirect!
			post locations_time_orders_url(locations_times(:one)), order: { payment_method: "1", recipient_name: "yo", recipient_phone: "47283"}
			assert_redirected_to shopper_cart_url(@shopper.role)
			assert_equal "Please remove unavailable or verify changed items before checkout", flash[:error]
			follow_redirect!
		end

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

		def cart_after_patch(obj)
			log_in_as @shopper
			#check cart
			get shopper_cart_url(@shopper.role)
			#patch triggers warning msgs
			assert_not flash[:warning].empty?
			assert_select 'a[href=?]', recipe_url(obj), text: obj.name, count: 1
		end

		def deactivate_recipe(obj)
			log_in_as @admin
			patch recipe_path(obj), recipe: { active: "0" }
			assert_not flash[:success].empty?
			assert_redirected_to manage_recipes_url
			follow_redirect!
			check_deactivate_result(obj)
		end
		
		def check_deactivate_result(obj)
			assert_select 'span.right.floated.error', text: "INACTIVE", count: 1
			assert_equal false, obj.reload.active
		end

		def cart_after_deactivate
			log_in_as @shopper
			get shopper_cart_url(@shopper.role)
			assert_not flash[:error].empty?
			assert_select 'div.ui.error.message', count: 2
		end

		def activate_recipe(obj)
			log_in_as @admin
			patch recipe_path(obj), recipe: { active: "1" }
			assert_not flash[:success].empty?
			assert_redirected_to manage_recipes_url
			follow_redirect!
			assert_select 'span.right.floated.success', text: "ACTIVE", count: 2
			assert_equal true, obj.reload.active
		end

		def cart_after_activate
			log_in_as @shopper
			get shopper_cart_url(@shopper.role)
			assert flash[:error].nil?
			assert_select 'div.ui.warning.message', count: 2
		end

		def confirm_changes(obj)
			patch orderable_url(obj), status: "0"
			assert_redirected_to shopper_cart_url(@shopper.role)
			follow_redirect!
			assert flash.empty?
			get shopper_checkout_url(@shopper.role)
			assert_response :success
			assert_template 'orders/new'
		end
end
