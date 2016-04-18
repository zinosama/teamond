require 'test_helper'

class OrderableCreateTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@dish = recipes(:dish1)
		@milktea = recipes(:milktea1)
	end

	test 'valid orderable' do
		log_in_as @user
		get cart_url
		assert_template 'orderables/index'
		assert_select 'a', text: @dish.name, count: 0
		assert_select 'div.value', text: "$ 0.0", count: 1

		assert_difference 'Orderable.count', 1 do
			post orderables_url, type: "dish", buyable_id: @dish.id
		end

		assert_redirected_to menu_url
		follow_redirect!
		assert_not flash.empty?

		#go to cart again
		get cart_url
		assert_select 'a', text: @dish.name, count: 1
		assert_select 'div.value', text: "$ #{@dish.price.to_f}", count: 1

		@dish.update_attribute(:active, false)
		get cart_url
		assert_not flash[:error].empty?
		assert_select 'p.error', text: "(NO LONGER AVAILABLE)", count: 1
		get summary_url
		assert_redirected_to cart_url
		assert_not flash[:error].empty?
	end

	test 'invalid orderable' do
		log_in_as @user
		assert_no_difference 'Orderable.count' do
			post orderables_url, type: "milktea", buyable_id: @milktea.id
		end
		assert_redirected_to menu_url
		assert_not flash[:error].empty?

		assert_no_difference 'Orderable.count' do
			post orderables_url, type: "dish", buyable_id: 12
		end
		assert_redirected_to menu_url
		assert_not flash[:error].empty?

		@dish.update_attribute(:active, false)
		assert_no_difference 'Orderable.count' do
			post orderables_url, type: "dish", buyable_id: @dish.id
		end
		assert_redirected_to menu_url
		assert_not flash[:error].empty?
	end

end
