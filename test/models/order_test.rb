require 'test_helper'

class OrderTest < ActiveSupport::TestCase

	def setup
		@user = users(:zino)
		@locations_time = locations_times(:one)
		@order = Order.new( total: 2.12, payment_method: 1, recipient_name: "zino", recipient_phone: "4329423", locations_time: @locations_time, user: @user )
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

	test 'payment_method should not be larger than 1' do
		@order.payment_method = 2
		assert_not @order.valid?
	end

	test 'payment_method should not be negative' do
		@order.payment_method = -1
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

	test 'should have a locations_time' do
		@order.locations_time_id = 11111
		assert_not @order.valid?
	end

	test 'should have user' do
		@order.user = nil
		assert_not @order.valid?
	end
end
