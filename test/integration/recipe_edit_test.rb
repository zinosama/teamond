require 'test_helper'

class RecipeEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@dish = recipes(:dish1)
		@milktea = recipes(:milktea1)
		@dish_cate2 = dish_categories(:cate2)

		@milktea_orderable = milktea_orderables(:milktea_orderable1)
		@orderable = orderables(:orderable2)
		@orderable.buyable = @milktea_orderable
		@orderable.ownable = @user
		@orderable.save
	end	

	test 'unsuccessful edit' do
		log_in_as @user
		get manage_recipes_url
		patch recipe_path(@dish), recipe: { name: "", price: "", type: "", image: "", description: "" }
		assert_template 'recipes/edit'
		assert_select 'li', count: 5
		assert_select 'div.ui.error.message', count: 1
	end

	test 'successful edit - dish' do
		log_in_as @user
		get manage_recipes_url
		patch recipe_path(@dish), recipe: { name: "edited", price: "100", type: "Milktea", dish_category_id: @dish_cate2.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		assert_not flash.empty?
		assert_redirected_to manage_recipes_url
		follow_redirect!
		#recipe is active in menu management
		assert_select 'span.right.floated.success', text: "ACTIVE", count: 2

		@dish.reload
		assert_equal "edited", @dish.name
		assert_equal 100, @dish.price
		assert_equal "edited", @dish.description
		assert_match "salad.jpg", @dish.image.model.image.file.file 

		#type cannot be changed
		assert_equal "Dish", @dish.type
		#dish_category can be changed if item is dish
		assert_equal @dish_cate2.id, @dish.dish_category_id

		#associate dish with two orderables
		orderable_one = Orderable.create!(buyable: @dish, ownable: @user, unit_price: @dish.price)
		orderable_two = Orderable.create!(buyable: @dish, ownable: users(:ed), unit_price: @dish.price)
		assert_equal 2, @dish.orderables.size
		#orderables' status default to 0
		assert_equal 0, orderable_one.status
		assert_equal 0, orderable_two.status
		#check cart
		get cart_url
		assert_equal true, flash.empty?
		assert_select 'a[href=?]', recipe_url(@dish), text: @dish.name, count: 1

		
		#deactivate
		patch recipe_path(@dish), recipe: { active: "0" }
		assert_not flash[:success].empty?
		assert_redirected_to manage_recipes_url
		follow_redirect!
		#recipe becomes inactive in menu management
		assert_select 'span.right.floated.success', text: "ACTIVE", count: 1
		assert_select 'span.right.floated.error', text: "INACTIVE", count: 1
		assert_equal false, @dish.reload.active
		#associated orderables' status change as well
		assert_equal 2, orderable_one.reload.status
		assert_equal 2, orderable_two.reload.status
		#check cart again
		get cart_url
		assert_not flash[:error].empty?
		assert_select 'div.ui.error.message', count: 2

		#should not be able to checkout
		checkout

		#activate
		patch recipe_path(@dish), recipe: { active: "1" }
		assert_not flash[:success].empty?
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_select 'span.right.floated.success', text: "ACTIVE", count: 2
		assert_select 'span.right.floated.error', text: "INACTIVE", count: 0
		assert_equal true, @dish.reload.active

		#check cart again
		get cart_url
		assert flash[:error].nil?
		assert_not flash[:warning].empty?
		assert_select 'div.ui.warning.message', count: 2

		#should not be able to checkout
		checkout

		#click on link to change orderable status from 1 to 0
		patch orderable_url(orderable_one, status: "0")
		assert_redirected_to cart_url
		follow_redirect!
		assert flash.empty?
		get summary_url
		assert_response :success
		assert_template 'orders/new'
	end

	test 'successful edit - milktea' do
		log_in_as @user
		get manage_recipes_url
		patch recipe_path(@milktea), recipe: { name: "edited", price: "100", type: "Dish", dish_category_id: @dish_cate2.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
		assert_not flash.empty?
		assert_redirected_to manage_recipes_url
		follow_redirect!
		@milktea.reload
		assert_equal "edited", @milktea.name
		assert_equal	100, @milktea.price
		assert_equal "edited", @milktea.description
		assert_match "salad.jpg", @milktea.image.model.image.file.file

		#type cannot be changed
		assert_equal "Milktea", @milktea.type
		#dish_category cannot be added if item is milktea
		assert_nil @milktea.dish_category_id

		#orderables' status default to 0
		assert_equal 0, @orderable.status
		#check cart
		get cart_url
		assert_not flash[:warning].empty?
		assert_select 'a[href=?]', recipe_url(@milktea), text: @milktea.name, count: 1
		
		#disable
		patch recipe_path(@milktea), recipe: { active: "0" }
		assert_not flash[:success].empty?
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_select 'span.right.floated.error', text: "INACTIVE", count: 1
		assert_equal false, @milktea.reload.active

		#check cart
		get cart_url
		assert_not flash[:error].empty?
		assert_select 'div.ui.error.message', count: 2

		checkout

		#activate
		patch recipe_path(@milktea), recipe: { active: "1" }
		assert_not flash[:success].empty?
		assert_redirected_to manage_recipes_url
		follow_redirect!
		assert_select 'span.right.floated.success', text: "ACTIVE", count: 2
		assert_equal true, @milktea.reload.active

		#check cart again
		get cart_url
		assert_select 'div.ui.warning.message', count: 2

		checkout

		#click on link to change orderable status from 1 to 0
		patch orderable_url(@orderable, status: "0")
		assert_redirected_to cart_url
		follow_redirect!
		assert flash.empty?
		get summary_url
		assert_response :success
		assert_template 'orders/new'		
	end

	private 

	def checkout
		get summary_url
		assert_redirected_to cart_url
		assert_not flash[:error].empty?
		follow_redirect!
		post locations_time_orders_url(locations_times(:one)), order: { payment_method: "1", recipient_name: "yo", recipient_phone: "47283"}
		assert_redirected_to cart_url
		assert_not flash[:error].empty?
		follow_redirect!
	end
end
