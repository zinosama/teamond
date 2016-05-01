require 'test_helper'

class MilkteaOrderableEditTest < ActionDispatch::IntegrationTest

	def setup
		@shopper = users(:ed)
		@milktea_orderable = orderables(:one).buyable

		@admin = users(:zino)
		@shopper2 = users(:shopper2)
	end

	test 'valid edit' do
		log_in_as @shopper
		
		#before edit, in cart
		get shopper_cart_url(@shopper.role)
		assert_select 'li', count: 0
		assert_select 'p', text: "Toppings:", count: 0
		assert_select 'span.ui.label', text: "regular size", count: 1
		assert_select 'span.ui.label', text: "half sweet", count: 1
		assert_select 'span.ui.label', text: "less ice", count: 1
		
		#edit
		get edit_milktea_orderable_url(@milktea_orderable)
		assert_template 'milktea_orderables/edit'
		assert_difference 'AddonsOrderable.count', 3 do
			patch milktea_orderable_url(@milktea_orderable), milktea_orderable: { sweet_scale: 0, temp_scale: 0, size: 1, milktea_addon_ids: get_addon_ids }
		end
		assert_redirected_to shopper_cart_url(@shopper.role)
		follow_redirect!
		assert_not flash[:success].empty?

		#check if orderable's unit_price has been updated
		total = @milktea_orderable.milktea.price + 0.99 + @milktea_orderable.milktea_addons.size * 0.5
		assert_equal(total.to_f, @milktea_orderable.orderable.reload.unit_price.to_f)

		#after edit, in cart
		MilkteaAddon.where("active = ?", true).each do |addon|
			assert_select 'div.ui.label', text: addon.name, count: 1
		end
		assert_select 'div.row', text: "Toppings:", count: 1
		assert_select 'span.ui.label', text: "large size", count: 1
		assert_select 'span.ui.label', text: "zero sweet", count: 1
		assert_select 'span.ui.label', text: "chill", count: 1

		#test destroy dependency for addons_orderable
		assert_difference 'AddonsOrderable.count', -3 do
			patch milktea_orderable_url(@milktea_orderable), milktea_orderable: { sweet_scale: 0, temp_scale: 0, size: 1, milktea_addon_ids: [""] }
		end
		assert_redirected_to shopper_cart_url(@shopper.role)
		follow_redirect!
		assert_not flash[:success].empty?
	end

	test 'cannot edit with invalid data' do
		log_in_as @shopper
		patch milktea_orderable_url(@milktea_orderable), milktea_orderable: { sweet_scale: "", temp_scale: 9, size: 3 }
		assert_template 'milktea_orderables/edit'
		assert_select 'div.ui.error.message', count: 1
		assert_select 'li', count: 4
	end

	test 'cannot edit record that belongs to other shopper' do
		#admin cannot edit
		log_in_as @admin
		assert_no_difference 'AddonsOrderable.count' do
			patch milktea_orderable_url(@milktea_orderable), milktea_orderable: { sweet_scale: 0, temp_scale: 0, size: 1, milktea_addon_ids: [""] }
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Access denied", flash[:error]
		varify_no_change
		
		#other shopper cannot edit
		log_in_as @shopper2
		assert_no_difference 'AddonsOrderable.count' do
			patch milktea_orderable_url(@milktea_orderable), milktea_orderable: { sweet_scale: 0, temp_scale: 0, size: 1, milktea_addon_ids: [""] }
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Access denied", flash[:error]
		varify_no_change
	end
	
	private 

		def varify_no_change 		
			@milktea_orderable.reload
			assert_equal 2, @milktea_orderable.sweet_scale
			assert_equal 1, @milktea_orderable.temp_scale
			assert_equal 0, @milktea_orderable.size
		end
end
