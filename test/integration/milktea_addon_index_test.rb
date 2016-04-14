require 'test_helper'

class MilkteaAddonIndexTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
		@user = users(:ed)
		@milktea = recipes(:milktea1)
	end

	test 'should list all addons in manage' do
		log_in_as @admin
		get manage_recipes_url

		MilkteaAddon.all.each do |addon|
			if addon.active
				assert_select 'a.ui.orange.tag.label[href=?]', edit_milktea_addon_url(addon), text: addon.name, count: 1
			else
				assert_select 'a.ui.red.tag.label[href=?]', edit_milktea_addon_url(addon), text: addon.name, count: 1
			end
		end
	end

	test 'should list active addons in milktea orderable create' do
		log_in_as @user
		get new_milktea_orderable_path(@milktea.id)
		assert_template 'milktea_orderables/new'
	
		assert_select 'form[id=?]',"newMilkteaOrderableForm", count: 1		
		#has a list of active addons
		MilkteaAddon.all.each do |addon|
			if addon.active
				assert_select "option", text: addon.name, count: 1
			else
				assert_select "option", text: addon.name, count: 0
			end
		end
	end

end
