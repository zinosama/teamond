require 'test_helper'

class OrderableEditTest < ActionDispatch::IntegrationTest

	def setup
		@shopper = users(:ed)
		@orderable = orderables(:one)
		@milktea_orderable = @orderable.buyable
	end

	test 'successful update' do
		log_in_as @shopper
		get shopper_cart_url(@shopper.role)
		assert_template 'orderables/index'

		assert_select 'a.title', text: @milktea_orderable.milktea.name, count: 1
		assert_select 'input[value="1"]', count: 1
		assert_select 'input[value="2"]', count: 0
		assert_select "form[action=\"#{orderable_path(@orderable)}\"]", count: 1
		
		#price before update
		assert_select 'div.value', text: "$ #{@orderable.unit_price}", count: 1

		patch orderable_url(@orderable), orderable: { quantity: "2" }
		assert_redirected_to shopper_cart_url(@shopper.role)
		follow_redirect!
		assert_not flash[:success].empty?

		assert_equal 2, @orderable.reload.quantity
		assert_select 'input[value = "2"]', count: 1
		assert_select 'input[value="1"]', count: 0

		#price after update
		assert_select 'div.value', text: "$ #{2 * @orderable.unit_price}", count: 1

		#set quantity to 0
		patch orderable_url(@orderable), orderable: { quantity: "0" }
		assert_redirected_to shopper_cart_url(@shopper.role)
		follow_redirect!
		assert_not flash[:success].empty?
		assert_select 'a.title', text: @milktea_orderable.milktea.name, count: 0
		assert_select 'div.value', text: "$ 0.0", count: 1
	end

	test 'unsuccessful update' do
		log_in_as @shopper
		get shopper_cart_url(@shopper.role)

		assert_select 'input[value="1"]', count: 1
		assert_select 'input[value = "2"]', count: 0

		patch orderable_url(@orderable), orderable: { quantity: 21 }
		assert_redirected_to shopper_cart_url(@shopper.role)
		follow_redirect!

		assert_equal "Quantity cannot be larger than 20", flash[:error]
		assert_equal 1, @orderable.reload.quantity
		assert_select 'input[value="1"]', count: 1
		assert_select 'input[value = "2"]', count: 0
	end

	test 'cannot update orderable of other shoppers' do
		shopper2 = users(:shopper2)
		log_in_as shopper2

		patch orderable_url(@orderable), orderable: { quantity: 2 }
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Access denied", flash[:error]
	end
end
