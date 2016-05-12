require 'test_helper'

class OrderTest < ActiveSupport::TestCase

	def setup
		@shopper = users(:ed).role
		@order = Order.new( total: 2.12, payment_method: 1, recipient_name: "zino", recipient_phone: "4329423", recipient_wechat: "213dfds", delivery_location: "location", delivery_time: DateTime.now, shopper: @shopper, satisfaction: 0 )
	end

	test 'should be valid' do
		assert @order.valid?
	end

	test 'should have total' do
		@order.total = ""
		assert_not @order.valid?
	end

	test 'total should be larger than 0' do
		@order.total = 0
		assert_not @order.valid?
		@order.total = -1
		assert_not @order.valid?
	end

	test 'should have payment_method' do
		@order.payment_method = ""
		assert_not @order.valid?
	end

	test 'should have recipient_name' do
		@order.recipient_name = ""
		assert_not @order.valid?
	end 

	test 'recipient_name should not be longer than 50 char' do
		@order.recipient_name = "a" * 51
		assert_not @order.valid?
	end

	test 'should have recipient_phone' do
		@order.recipient_phone = ""
		assert_not @order.valid?
	end

	test 'recipient_phone should not be longer than 60 char' do
		@order.recipient_phone = "a" * 61
		assert_not @order.valid?
	end

	test 'recipient_wechat should not be longer than 50 char' do
		@order.recipient_wechat = "a" * 51
		assert_not @order.valid?
	end

	test 'should have shopper' do
		@order.shopper = nil
		assert_not @order.valid?
	end

	test 'issue should not be too long' do
		@order.issue = "a" * 256
		assert_not @order.valid?
	end	

	test 'should have a delivery location' do
		@order.delivery_location = ""
		assert_not @order.valid?
	end

	test 'should have a delivery time' do
		@order.delivery_time = nil
		assert_not @order.valid?
	end

	test 'solution should not be too long' do
		@order.solution = "a" * 256
		assert_not @order.valid?
	end

	test 'note should not be too long' do
		@order.note = "a" * 256
		assert_not @order.valid?
	end
end

