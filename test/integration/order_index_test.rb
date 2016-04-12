require 'test_helper'

class OrderIndexTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:ed)
		@order = orders(:two)
		@admin = users(:zino)
	end

	test 'user index should list correct items' do
		log_in_as @user
		get user_orders_url(@user)
		assert_select 'div.ui.fluid.card', count: 1
		assert_select 'form[action=?]', order_path(@order), count: 1
		assert_select 'a[href=?]', order_url(@order), count: 1
	end

	test 'admin index should list correct items' do
		log_in_as @admin
		get user_orders_url(@admin)
		assert_select 'div.adminOrderCard', count: 2
		assert_select 'a[href=?]', order_url(@order), count: 1
		assert_select 'form[action=?]', order_path(@order), count: 1
	end

	test 'admin unpaid filter is valid' do
		log_in_as @admin
		create_order(:paid)
		assert_equal 3, Order.count

		get user_orders_url(@admin, query: "unpaid")
		assert_select 'div.adminOrderCard', count: 2
	end

	test 'admin unfulfilled filter is valid' do
		log_in_as @admin
		create_order(:fulfilled)
		assert_equal 3, Order.count

		get user_orders_url(@admin, query: "unfulfilled")
		assert_select 'div.adminOrderCard', count: 2
	end

	test 'admin fulfilled filter is valid' do
		log_in_as @admin
		create_order(:fulfilled)
		assert_equal 3, Order.count

		get user_orders_url(@admin, query: "fulfilled")
		assert_select 'div.adminOrderCard', count: 1
	end

	test 'admin problemed filter is valid' do
		log_in_as @admin
		create_order(:pending_issue)
		create_order(:resolved_issue)
		assert_equal 4, Order.count
		
		get user_orders_url(@admin, query: "complained")
		assert_select 'div.adminOrderCard', count: 1
	end

	test 'admin resolved filter is valid' do
		log_in_as @admin
		create_order(:pending_issue)
		create_order(:resolved_issue)
		assert_equal 4, Order.count

		get user_orders_url(@admin, query: "resolved")
		assert_select 'div.adminOrderCard', count: 1
	end

	private 

	def create_order(type)
		if type == :paid
			Order.create( user: @user, total: 10, payment_method: 1, payment_status: 1, delivery_location: locations_times(:one).pickup_location.name, delivery_time: locations_times(:one).pickup_time_datetime, recipient_name: "zinosama", recipient_phone: 3248738 )
		elsif type == :fulfilled
			Order.create( user: @user, total: 10, payment_method: 1, payment_status: 1, delivery_location: locations_times(:one).pickup_location.name, delivery_time: locations_times(:one).pickup_time_datetime, recipient_name: "zinosama", fulfillment_status: 1, recipient_phone: 3248738 )
		elsif type == :pending_issue
			Order.create( user: @user, total: 10, payment_method: 1, delivery_location: locations_times(:one).pickup_location.name, delivery_time: locations_times(:one).pickup_time_datetime, recipient_name: "zinosama", recipient_phone: 3248738, issue_status: 2, issue: "hi")
		elsif type == :resolved_issue
			Order.create( user: @user, total: 10, payment_method: 1, delivery_location: locations_times(:one).pickup_location.name, delivery_time: locations_times(:one).pickup_time_datetime, recipient_name: "zinosama", recipient_phone: 3248738, issue_status: 3, issue: "hi")
		end
	end
end
