require 'test_helper'

class MilkteaOrderableCreateTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:ed)
		@milktea = recipes(:milktea1)
	end

	test 'invalid milktea orderable - invalid milktea id submission' do
		log_in_as(@user)
		get new_milktea_orderable_path @milktea.id
		assert_template 'milktea_orderables/new'
		post milktea_orderables_path @milktea.id, milktea_orderable: { sweet_scale: "", temp_scale: "", size: "", milktea_id: "" } 
		assert_redirected_to menu_url
		assert_not flash.empty?
	end

	test 'invalid milktea orderable - valid milktea id submission' do
		log_in_as(@user)
		get new_milktea_orderable_path @milktea.id
		post milktea_orderables_path @milktea.id, milktea_orderable: { sweet_scale: "", temp_scale: "", size: "", milktea_id: @milktea.id } 
		assert_template 'milktea_orderables/new'
		assert_select 'div.ui.error.message', count: 1
		assert_select 'li', count: 6
	end

	test 'valid milktea orderable - create correct addons_orderable' do
		addon_ids = get_addon_ids
		log_in_as(@user)
		assert_difference 'AddonsOrderable.count', 3 do
			post milktea_orderables_path @milktea.id, milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_id: @milktea.id, milktea_addon_ids: addon_ids }
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_template 'recipes/index'
		assert_not flash.empty?
	end

	test 'valid milktea orderable - create correct orderable' do
		log_in_as(@user)
		assert_difference 'Orderable.count', 1 do
			post milktea_orderables_path @milktea.id, milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_id: @milktea.id, milktea_addon_ids: get_addon_ids }
		end
	end

end
