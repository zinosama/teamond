require 'test_helper'

class MilkteaAddonEditTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
		@addon = milktea_addons(:inactive_addon)
	end

	test 'valid update' do
		log_in_as @admin

		get edit_milktea_addon_url(@addon)
		assert_template 'milktea_addons/edit'
		#checking the two button on edit page
		assert_select 'input.ui.inverted.red.button', count: 1
		assert_select 'input.ui.inverted.orange.button', count: 1

		get manage_recipes_url
		#initial active status
		assert_select 'a.ui.red.tag.label', text: @addon.name, count: 1
		assert_equal false, @addon.active

		#patch on name and price
		patch milktea_addon_url(@addon), milktea_addon: { name: 'new_name', price: 0.8 }
		assert_equal 0.8, @addon.reload.price
		assert_equal 'new_name', @addon.reload.name

		assert_redirected_to manage_recipes_url
		assert_not flash[:success].empty?

		follow_redirect!
		#active status is unchanged
		assert_select 'a.ui.red.tag.label', text: 'new_name', count: 1
		assert_equal false, @addon.reload.active

		#activate item
		patch milktea_addon_url(@addon), milktea_addon: { active: "1" }
		assert_equal true, @addon.reload.active
		assert_redirected_to manage_recipes_url
		
		follow_redirect!
		assert_not flash[:success].empty?
		#turns to orange from red
		assert_select 'a.ui.red.tag.label', text: 'new_name', count: 0
		assert_select 'a.ui.orange.tag.label', text: 'new_name', count: 1

		#visit edit page again to see a different red diasbled button
		get edit_milktea_addon_url(@addon)
		assert_select 'input.ui.inverted.red.button.disabled', count: 1

		#deactivate item
		patch milktea_addon_url(@addon), milktea_addon: { active: "0" }
		assert_equal false, @addon.reload.active
		assert_redirected_to manage_recipes_url

		follow_redirect!
		assert_not flash[:success].empty?
		assert_select 'a.ui.red.tag.label', text: 'new_name', count: 1
	end

	test 'invalid update' do
		log_in_as @admin
		patch milktea_addon_url(@addon), milktea_addon: { name: '', price: '' }
		assert_template 'milktea_addons/edit'
		assert_select 'div.error.message', count: 1
		assert_select 'li', count: 3
	end
end
