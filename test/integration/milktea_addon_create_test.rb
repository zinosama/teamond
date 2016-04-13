require 'test_helper'

class MilkteaAddonCreateTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
	end

	test 'valid addon' do
		log_in_as @admin
		get manage_recipes_url
		assert_select 'form[id=?]', 'new_milktea_addon', count: 1
		assert_select 'a.ui.tag.label', text: "new_addon", count: 0

		assert_difference 'MilkteaAddon.count', 1 do
			post milktea_addons_url, milktea_addon: { name: "new_addon", price: 0.5 } 
		end
		addon = assigns(:milktea_addon)
		assert_equal false, addon.active

		assert_redirected_to manage_recipes_url
		assert_not flash[:success].empty?

		follow_redirect!
		assert_select 'a.ui.red.tag.label[href=?]', edit_milktea_addon_url(addon), text: "new_addon", count: 1
	end

	test 'invalid addon' do
		log_in_as @admin
		assert_no_difference 'MilkteaAddon.count' do
			post milktea_addons_url, milktea_addon: { name: "", price: "" }
		end
		assert_template 'shared/manage'
		assert_select 'div.error.message', count: 1
		assert_select 'li', count: 3
	end
end
