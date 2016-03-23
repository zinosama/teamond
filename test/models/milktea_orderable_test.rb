require 'test_helper'

class MilkteaOrderableTest < ActiveSupport::TestCase

	def setup
		milktea = recipes(:milktea1)
		@milktea_orderable = MilkteaOrderable.new(sweet_scale: 3, temp_scale: 2, size: 1, milktea: milktea)
	end

	test 'should be valid' do
		assert @milktea_orderable.valid?
	end

	test 'sweet scale should be larger than or equal 0' do 
		@milktea_orderable.sweet_scale = -1
		assert_not @milktea_orderable.valid?
	end

	test 'sweet scale should be less than 5' do
		@milktea_orderable.sweet_scale = 5
		assert_not @milktea_orderable.valid?
	end

	test 'sweet scale should be present' do
		@milktea_orderable.sweet_scale = ''
		assert_not @milktea_orderable.valid?
	end

	test 'temp_scale should be larger than or equal to 0' do
		@milktea_orderable.temp_scale = -1
		assert_not @milktea_orderable.valid?
	end

	test 'temp_scale should be less than 4' do
		@milktea_orderable.temp_scale = 4
		assert_not @milktea_orderable.valid?
	end

	test 'temp_scale should be present' do
		@milktea_orderable.temp_scale = ''
		assert_not @milktea_orderable.valid?
	end

	test 'size should be larger than or equal to 0' do
		@milktea_orderable.size = -1
		assert_not @milktea_orderable.valid?
	end

	test 'size should be less than 2' do 
		@milktea_orderable.size = 2
		assert_not @milktea_orderable.valid?
	end

	test 'size should be present' do
		@milktea_orderable.size = ''
		assert_not @milktea_orderable.valid?
	end

	test 'should have a milktea recipe' do
		@milktea_orderable.milktea = nil
		assert_not @milktea_orderable.valid?
	end	

	test 'should have correct association (milktea_component, milktea_addon, orderable)' do
		@milktea_orderable.milktea_addon_ids = get_addon_ids
		@milktea_orderable.save

		assert_equal 3, @milktea_orderable.addons_orderables.size
		stored_addon_ids = @milktea_orderable.addons_orderables.map{ |component| component.milktea_addon.id }
		assert_equal get_addon_ids.sort, stored_addon_ids.sort  

		total = @milktea_orderable.milktea.price + 1.5 + 0.99
		assert_equal total, @milktea_orderable.orderable.unit_price
	end
end
