require 'test_helper'

class MilkteaAddonTest < ActiveSupport::TestCase
	
	def setup
		@milktea_addon = MilkteaAddon.new( name: "bubble", price: 0.5 )
	end

	test 'should be valid' do
		assert @milktea_addon.valid?
	end

	test 'name should not be too long' do
		@milktea_addon.name = "a" * 51
		assert_not @milktea_addon.valid?
	end

	test 'name should be present' do
		@milktea_addon.name = " "
		assert_not @milktea_addon.valid?
	end

	test 'price should be present' do
		@milktea_addon.price = nil
		assert_not @milktea_addon.valid?
	end

	test 'price should be positive number' do
		@milktea_addon.price = 0
		assert_not @milktea_addon.valid?
		@milktea_addon.price = -1.2
		assert_not @milktea_addon.valid?
	end

end
