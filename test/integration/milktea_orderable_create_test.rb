require 'test_helper'
class MilkteaOrderableCreateTest < ActionDispatch::IntegrationTest

	def setup
		@shopper = users(:ed)
		@milktea = recipes(:milktea1)
		@admin = users(:zino)
	end

	test 'invalid milktea orderable - invalid milktea id submission' do
		log_in_as @shopper
		get new_milktea_milktea_orderable_path @milktea
		assert_template 'milktea_orderables/new'
		post shopper_milktea_orderables_path(@shopper.role), milktea_orderable: { sweet_scale: "", temp_scale: "", size: "" }, milktea_id: ""
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Invalid milktea. Please contact customer service", flash[:error]
	end

	test 'invalid milktea orderable - valid milktea id submission' do
		log_in_as @shopper
		get new_milktea_milktea_orderable_path @milktea
		post shopper_milktea_orderables_path(@shopper.role), milktea_orderable: { sweet_scale: "", temp_scale: "", size: "" }, milktea_id: @milktea.id 
		assert_template 'milktea_orderables/new'
		assert_select 'div.ui.error.message', count: 1
		assert_select 'li', count: 6
	end

	test 'invalid milktea orderable - inactive milktea' do
		@milktea.update_attribute(:active, false)
		log_in_as @shopper
		get new_milktea_milktea_orderable_path @milktea
		post shopper_milktea_orderables_path(@shopper.role), milktea_orderable: { sweet_scale: "", temp_scale: "", size: "" }, milktea_id: @milktea.id 
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Inactive milktea. Please contact customer service", flash[:error]
	end

	test 'valid milktea orderable - create correct addons_orderable' do
		addon_ids = get_addon_ids
		log_in_as @shopper
		assert_difference 'AddonsOrderable.count', 3 do
			post shopper_milktea_orderables_path(@shopper.role), milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_addon_ids: addon_ids }, milktea_id: @milktea.id
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_template 'recipes/index'
		assert_not flash[:success].empty?
	end

	test 'valid milktea orderable - create correct orderable in cart' do
		log_in_as @shopper
		assert_difference 'Orderable.count', 1 do
			post shopper_milktea_orderables_path(@shopper.role), milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_addon_ids: get_addon_ids }, milktea_id: @milktea.id
		end
		milktea_orderable = assigns(:milktea_orderable)

		#orderable unit_price is set correctly
		total = milktea_orderable.milktea.price + 0.99 + milktea_orderable.milktea_addons.size * 0.5
		assert_equal total, milktea_orderable.orderable.unit_price

		#appears in shopping cart correctly
		get shopper_cart_url(@shopper.role)
		assert_select 'a[href=?]', edit_milktea_orderable_url(milktea_orderable)
		assert_select 'a[href=?]', recipe_url(milktea_orderable.milktea), count: 4
		assert_select 'a', text: milktea_orderable.milktea.name, count: 2
		assert_select 'p', text: "$ #{total}", count: 1
		MilkteaAddon.where("active = ?", true).each do |addon|
			assert_select 'div.ui.label', text: addon.name, count: 1
		end
		assert_select 'div.value', text: "$ #{total.to_f + 2.12}", count: 1
	end

	test 'only shopper can create milktea orderable' do
		log_in_as @admin

		#milktea orderable #new
		get new_milktea_milktea_orderable_path(@milktea)
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Access denied", flash[:error]

		#milktea orderable #create
		assert_no_difference 'Orderable.count' do
			post shopper_milktea_orderables_path(@admin.role), milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_addon_ids: get_addon_ids }, milktea_id: @milktea.id
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_not flash[:error].empty?
	end

	test 'can only create milktea orderable in own cart' do
		shopper2 = users(:shopper2)

		log_in_as @shopper

		assert_no_difference 'Orderable.count' do
			post shopper_milktea_orderables_path(shopper2.role), milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_addon_ids: get_addon_ids }, milktea_id: @milktea.id
		end
		assert_redirected_to menu_url
		follow_redirect!
		assert_equal "Unauthorized request", flash[:error]
	end
end
