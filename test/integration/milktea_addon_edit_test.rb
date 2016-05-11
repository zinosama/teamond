require 'test_helper'

class MilkteaAddonEditTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
		@shopper = users(:ed)
		@addon = milktea_addons(:inactive_addon)
		@milktea = recipes(:milktea1)
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
		@addon.reload
		assert_equal true, @addon.active
		assert_redirected_to manage_recipes_url
		
		follow_redirect!
		assert_not flash[:success].empty?
		#turns to orange from red
		assert_select 'a.ui.red.tag.label', text: 'new_name', count: 0
		assert_select 'a.ui.orange.tag.label', text: 'new_name', count: 1

		#visit edit page again to see a different red diasbled button
		get edit_milktea_addon_url(@addon)
		assert_select 'input.ui.inverted.red.button.disabled', count: 1

		#create associated orderable
		log_in_as @shopper
		post shopper_milktea_orderables_url(@shopper.role), milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_addon_ids: [@addon.id] }, milktea_id: @milktea.id
		milktea_orderable = assigns(:milktea_orderable)
		assert_redirected_to menu_url
		assert_not flash[:success].empty?

		orderable = milktea_orderable.orderable

		assert_equal 0, orderable.status

		#deactivate addon
		log_in_as @admin
		patch milktea_addon_url(@addon), milktea_addon: { active: "0" }
		assert_equal false, @addon.reload.active
		assert_redirected_to manage_recipes_url
		follow_redirect!

		assert_not flash[:success].empty?
		assert_select 'a.ui.red.tag.label', text: 'new_name', count: 1

		#assert status change of associated orderable
		assert_equal 2, orderable.reload.status

		log_in_as @shopper
		get shopper_cart_url(@shopper.role)
		assert_not flash[:error].empty?
		assert_select 'div.ui.error.message', count: 2

		checkout

		#reactivate addon
		log_in_as @admin
		patch milktea_addon_url(@addon), milktea_addon: { active: "1" }
		assert_equal true, @addon.reload.active
		assert_redirected_to manage_recipes_url
		follow_redirect!
		
		assert_not flash[:success].empty?
		assert_select 'a.ui.orange.tag.label', text: 'new_name', count: 1

		#assert status change of associated orderable
		assert_equal 1, orderable.reload.status

		log_in_as @shopper
		get shopper_cart_url(@shopper.role)
		assert_not flash[:warning].empty?
		assert_select 'div.ui.warning.message', count: 2

		checkout

		#deactivate addon again
		log_in_as @admin
		patch milktea_addon_url(@addon), milktea_addon: { active: "0" }
		follow_redirect!

		#remove addon from milktea orderable
		log_in_as @shopper
		patch milktea_orderable_url(milktea_orderable), milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_id: recipes(:milktea1).id, milktea_addon_ids: [""] }
		assert_redirected_to shopper_cart_url(@shopper.role)
		follow_redirect!
		milktea_orderable.reload

		assert_equal 0, orderable.reload.status
		get shopper_cart_url(@shopper.role)
		assert_equal true, flash.empty?
		get shopper_checkout_url(@shopper.role)
		assert_response :success
	end

	test 'invalid update' do
		log_in_as @admin
		patch milktea_addon_url(@addon), milktea_addon: { name: '', price: '' }
		assert_template 'milktea_addons/edit'
		assert_select 'div.error.message', count: 1
		assert_select 'li', count: 3
	end

	private 

	def checkout
		get shopper_checkout_url(@shopper.role)
		assert_redirected_to shopper_cart_url(@shopper.role)
		assert_not flash[:error].empty?
		follow_redirect!
		post locations_time_orders_url(locations_times(:one)), order: { payment_method: "1", recipient_name: "yo", recipient_phone: "47283"}
		assert_redirected_to shopper_cart_url(@shopper.role)
		assert_not flash[:error].empty?
		follow_redirect!
	end
end
