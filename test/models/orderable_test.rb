require 'test_helper'

class OrderableTest < ActiveSupport::TestCase
	
	def setup
		@shopper = users(:ed)
		@dish = recipes(:dish1)
		@order = orders(:order1)
	end

	test 'belongs to user' do
		orderable = @shopper.role.orderables.build(unit_price: 10, quantity: 1)
		assert_equal @shopper.role, orderable.ownable
	end

	test 'belongs to order' do
		orderable = @shopper.role.orderables.build(unit_price:10, quantity: 1)
		assert_equal @shopper.role, orderable.ownable
	end

	test 'belongs to dish' do
		orderable = @shopper.role.orderables.build(unit_price:10, quantity: 1)
		orderable.buyable = @dish
		assert_equal @dish, orderable.buyable
	end

	test 'should be valid' do
		orderable = Orderable.new(buyable: @dish, ownable: @shopper.role, unit_price: 10, quantity: 20)
		assert orderable.valid?
	end

	test 'quantity cannot be large than 20' do
		orderable = Orderable.new(buyable: @dish, ownable: @shopper.role, unit_price: 10, quantity: 21)
		assert_not orderable.valid?
	end

	test 'unit_price should be present' do
		orderable = Orderable.new(buyable: @dish, ownable: @shopper.role, quantity: 20)
		assert_not orderable.valid?
	end

	test 'buyable should be present' do
		orderable = Orderable.new(ownable: @user, unit_price: 10, quantity: 20)
		assert_not orderable.valid?
	end

	test 'ownable should be present' do
		orderable = Orderable.new(buyable: @dish, unit_price: 10, quantity: 20)
		assert_not orderable.valid?
	end

end
