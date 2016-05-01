require 'test_helper'

class OrderableDestroyTest < ActionDispatch::IntegrationTest

	def setup
		@shopper = users(:ed)
		@orderable = orderables(:one)
		@orderable.buyable.update!(milktea_addon_ids: get_addon_ids)

		@admin = users(:zino)
		@shopper2 = users(:shopper2)
	end

	test 'successfully destroy self' do
		log_in_as @shopper 
		get shopper_cart_url(@shopper.role)
		assert_template 'orderables/index'

		assert_select 'a[href=?]', edit_milktea_orderable_url(@orderable.buyable), count: 1
		assert_select 'a[href=?]', orderable_url(@orderable.id), count: 1

		assert_difference 'Orderable.count', -1 do
			delete orderable_url(@orderable) 
		end

		assert_redirected_to shopper_cart_url(@shopper.role)
		follow_redirect!
		assert_not flash[:success].empty?

		assert_select 'a[href=?]', edit_milktea_orderable_url(@orderable.buyable), count: 0
		assert_select 'a[href=?]', orderable_url(@orderable.id), count: 0
	end

	test 'successfully destroy associated milktea orderable' do
		log_in_as @shopper
		assert_difference 'MilkteaOrderable.count', -1 do
			delete orderable_url(@orderable) 
		end
	end

	test 'successfully destroy associated addons_orderables' do
		log_in_as @shopper
		assert_difference 'AddonsOrderable.count', -3 do
			delete orderable_url(@orderable) 
		end
	end

	test 'cannot destroy orderable that does not belong to self' do
		log_in_as @admin
		assert_no_difference 'Orderable.count' do
			delete orderable_url(@orderable) 
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Access denied", flash[:error]

		log_in_as @shopper2
		assert_no_difference 'Orderable.count' do
			delete orderable_url(@orderable) 
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Access denied", flash[:error]
	end
	
end
