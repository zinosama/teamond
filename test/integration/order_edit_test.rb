require 'test_helper'

class OrderEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:zino)
		@order = orders(:order1)
	end

	test 'only satisfaction and issue can be updated' do
		log_in_as @user 
		get order_url(@order)
		assert_template 'orders/show'

		patch order_url(@order), order: { total: 301, satisfaction: 3, issue: "issue" }
		assert_redirected_to order_url(@order)
		assert_not flash.empty?

		assert_equal 3, @order.reload.satisfaction
		assert_equal "issue", @order.reload.issue
		assert_equal @order.total, @order.reload.total
	end

	test 'invalid update' do
		log_in_as @user
		patch order_url(@order), order: { satisfaction: 6, issue: "a"*256 }
		assert_template 'orders/show'
		assert_equal "Error. Please limit your feedback to under 255 characters.", flash.now[:error]
	end	
end
