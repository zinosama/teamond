require 'test_helper'

class OrderIndexTest < ActionDispatch::IntegrationTest

	def setup
		@shopper = users(:ed)
		@order = orders(:two)
		@admin = users(:zino)
	end

	test 'shopper index should list correct items' do
		log_in_as @shopper
		get shopper_orders_url(@shopper.role)
		assert_select 'div.ui.fluid.card', count: 2
		assert_select 'form[action=?]', order_path(@order), count: 1
		assert_select 'a[href=?]', order_url(@order), count: 1
	end

	test 'admin index should list correct items' do
		log_in_as @admin
		get admin_orders_url(@admin.role)
		assert_select 'div.adminOrderCard', count: 2
		assert_select 'a[href=?]', order_url(@order), count: 1
		assert_select 'form[action=?]', order_path(@order), count: 1
	end

	test 'admin unpaid filter is valid' do
		log_in_as @admin
		create_order(:paid)
		assert_equal 3, Order.count

		get admin_orders_url(@admin.role), query: "unpaid"
		assert_select 'div.adminOrderCard', count: 2
	end

	test 'admin unfulfilled filter is valid' do
		log_in_as @admin
		create_order(:fulfilled)
		assert_equal 3, Order.count

		get admin_orders_url(@admin.role), query: "unfulfilled"
		assert_select 'div.adminOrderCard', count: 2
	end

	test 'admin fulfilled filter is valid' do
		log_in_as @admin
		create_order(:fulfilled)
		assert_equal 3, Order.count

		get admin_orders_url(@admin.role), query: "fulfilled"
		assert_select 'div.adminOrderCard', count: 1
	end

	test 'admin problemed filter is valid' do
		log_in_as @admin
		create_order(:pending_issue)
		create_order(:closed_issue)
		assert_equal 4, Order.count
		
		get admin_orders_url(@admin.role), query: "complained"
		assert_select 'div.adminOrderCard', count: 1
	end

	test 'admin resolved filter is valid' do
		log_in_as @admin
		create_order(:pending_issue)
		create_order(:closed_issue)
		assert_equal 4, Order.count

		get admin_orders_url(@admin.role), query: "resolved"
		assert_select 'div.adminOrderCard', count: 1
	end

	private 

	def create_order(type)
		if type == :paid
			Order.create( shopper: @shopper.role, total: 10, payment_method: 1, payment_status: 1, delivery_location: locations_times(:one).pickup_location.name, delivery_time: locations_times(:one).pickup_time_datetime, recipient_name: "zinosama", recipient_phone: 3248738 )
		elsif type == :fulfilled
			Order.create( shopper: @shopper.role, total: 10, payment_method: 1, payment_status: 1, delivery_location: locations_times(:one).pickup_location.name, delivery_time: locations_times(:one).pickup_time_datetime, recipient_name: "zinosama", fulfillment_status: 1, recipient_phone: 3248738 )
		elsif type == :pending_issue
			Order.create( shopper: @shopper.role, total: 10, payment_method: 1, delivery_location: locations_times(:one).pickup_location.name, delivery_time: locations_times(:one).pickup_time_datetime, recipient_name: "zinosama", recipient_phone: 3248738, issue_status: 1, issue: "hi")
		elsif type == :closed_issue
			Order.create( shopper: @shopper.role, total: 10, payment_method: 1, delivery_location: locations_times(:one).pickup_location.name, delivery_time: locations_times(:one).pickup_time_datetime, recipient_name: "zinosama", recipient_phone: 3248738, issue_status: 2, issue: "hi")
		end
	end
end
