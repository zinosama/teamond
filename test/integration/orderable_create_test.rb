require 'test_helper'

class OrderableCreateTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
		@provider = users(:provider)
		@driver = users(:driver)
		@shopper = users(:ed)

		@dish = recipes(:dish1)
		@milktea = recipes(:milktea1)
	end

	test 'valid orderable' do
		invalid_access_to_cart @admin
		invalid_access_to_cart @driver
		invalid_access_to_cart @provider

		log_in_as @shopper
		get shopper_cart_url(@shopper.role)
		assert_template 'orderables/index'
		assert_select 'a', text: @dish.name, count: 0
		assert_select 'div.value', text: "$ 0.0", count: 1

		assert_difference 'Orderable.count', 1 do
			post shopper_orderables_url(@shopper.role), type: "dish", buyable_id: @dish.id
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_not flash[:success].empty?

		#go to cart again
		get shopper_cart_url(@shopper.role)
		assert_select 'a.title', text: @dish.name, count: 1
		assert_select 'input[value=?]', "1", count: 1
		assert_select 'input[value=?]', "2", count: 0
		assert_select 'div.value', text: "$ #{@dish.price.to_f}", count: 1

		#add same item to cart again
		assert_no_difference 'Orderable.count' do 
			post shopper_orderables_url(@shopper.role), type: "dish", buyable_id: @dish.id
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_not flash[:success].empty?

		get shopper_cart_url(@shopper.role)
		assert_select 'input[value=?]', "1", count: 0
		assert_select 'input[value=?]', "2", count: 1
		assert_select 'div.value', text: "$ #{2 * @dish.price.to_f}", count: 1
	end

	test 'invalid orderable' do
		log_in_as @shopper

		#invalid buyable type error
		assert_no_difference 'Orderable.count' do
			post shopper_orderables_url(@shopper.role), type: "milktea", buyable_id: @milktea.id
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Invalid request. Please contact customer service", flash[:error]

		#invalid dish error
		assert_no_difference 'Orderable.count' do
			post shopper_orderables_url(@shopper.role), type: "dish", buyable_id: 12
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Invalid item. Please contact customer service", flash[:error]

		#inactive error
		@dish.update_attribute(:active, false)
		assert_no_difference 'Orderable.count' do
			post shopper_orderables_url(@shopper.role), type: "dish", buyable_id: @dish.id
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Inactive item. Please contact customer service", flash[:error]
	end

	private

		def invalid_access_to_cart(user)
			log_in_as user
			get shopper_cart_url(user.role)
			assert_redirected_to menu_url
			follow_redirect!
			assert_equal "Invalid request", flash[:error]
		end
end
