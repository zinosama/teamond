require 'test_helper'

class OrderableDestroyTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		milktea_orderable = milktea_orderables(:milktea_orderable1)
		milktea_orderable.update(milktea_addon_ids: get_addon_ids)
		@orderable = orderables(:orderable2)
		@orderable.ownable = @user
		@orderable.buyable = milktea_orderable
		@orderable.save
	end

	test 'successfully destroy self' do
		log_in_as @user 
		get cart_url
		assert_template 'orderables/index'

		assert_select 'a[href=?]', edit_milktea_orderable_url(@orderable.buyable), count: 1
		assert_select 'a[href=?]', orderable_url(@orderable.id), count: 1

		assert_difference 'Orderable.count', -1 do
			delete orderable_url(@orderable) 
		end

		assert_redirected_to cart_url
		assert_not flash.empty?
	end

	test 'successfully destroy associated milktea orderable' do
		log_in_as @user
		assert_difference 'MilkteaOrderable.count', -1 do
			delete orderable_url(@orderable) 
		end
	end

	test 'successfully destroy associated addons_orderables' do
		log_in_as @user
		assert_difference 'AddonsOrderable.count', -4 do
			delete orderable_url(@orderable) 
		end
	end
end
