require 'test_helper'

class MilkteaOrderableEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		orderable = orderables(:orderable2)
		orderable.ownable = @user
		@milktea_orderable = milktea_orderables(:milktea_orderable1)
		@milktea_orderable.orderable = orderable
	end

	test 'successful edit' do
		log_in_as @user
		
		#before edit, in cart
		get cart_url
		assert_select 'li', count: 0
		assert_select 'p', text: "Toppings:", count: 0
		assert_select 'span.ui.label', text: "regular size", count: 1
		assert_select 'span.ui.label', text: "half sweet", count: 1
		assert_select 'span.ui.label', text: "less ice", count: 1
		
		#edit
		get edit_milktea_orderable_url(@milktea_orderable)
		assert_template 'milktea_orderables/edit'
		assert_difference 'AddonsOrderable.count', 3 do
			patch milktea_orderable_url(@milktea_orderable), milktea_orderable: { sweet_scale: 0, temp_scale: 0, size: 1, milktea_id: @milktea_orderable.milktea.id, milktea_addon_ids: get_addon_ids }
		end
		assert_redirected_to cart_url
		follow_redirect!
		assert_not flash.empty?

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
			patch milktea_orderable_url(@milktea_orderable), milktea_orderable: { sweet_scale: 0, temp_scale: 0, size: 1, milktea_id: @milktea_orderable.milktea.id, milktea_addon_ids: [""] }
		end
		assert_redirected_to cart_url
		follow_redirect!
		assert_not flash.empty?
	end

	test 'unsuccessful edit' do
		log_in_as @user
		patch milktea_orderable_url(@milktea_orderable), milktea_orderable: { sweet_scale: "", temp_scale: 9, size: 3 }
		assert_template 'milktea_orderables/edit'
		assert_select 'div.ui.error.message', count: 1
		assert_select 'li', count: 4
	end
	
end
