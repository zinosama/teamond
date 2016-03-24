require 'test_helper'

class OrderTest < ActiveSupport::TestCase

	def setup
		@user = users(:zino)
		@order = Order.new( total: 2.12, payment_method: 1, paid: false, user: @user )
	end

	test 'should be valid' do
		assert @order.valid?
	end

	test 'should have total' do
		@order.total = ""
		assert_not @order.valid?
	end

	test 'total should be number' do
		@order.total = "Hi"
		assert_not @order.valid?
	end

	test 'should have payment_method' do
		@order.payment_method = ""
		assert_not @order.valid?
	end

	test 'payment_method should not be larger than 1' do
		@order.payment_method = 2
		assert_not @order.valid?
	end

	test 'payment_method should not be negative' do
		@order.payment_method = -1
		assert_not @order.valid?
	end	

	test 'should have user' do
		@order.user = nil
		assert_not @order.valid?
	end
end
