require 'test_helper'

class OrderEditTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:ed)
		@order = orders(:two)
		@admin = users(:zino)
	end

	test 'valid update by user' do
		log_in_as @user 
		get order_url(@order)
		assert_template 'orders/show'

		assert_equal 0, @order.issue_status
		assert_select 'div.ui.huge.heart.rating', count: 1
		assert_select 'textarea[name=?]', 'order[issue]', count: 1
		assert_select 'span.success', text: "This order has no issue", count: 1

		patch order_url(@order), order: { total: 301, satisfaction: 3, issue: "issue" }
		assert_redirected_to order_url(@order)
		assert_not flash.empty?
		follow_redirect!
		assert_template 'orders/show'

		#record has been updated
		assert_equal 3, @order.reload.satisfaction
		assert_equal "issue", @order.reload.issue
		assert_equal 1, @order.reload.issue_status

		#view has changed after issue is submitted
		assert_select 'div.ui.huge.heart.rating', count: 0
		assert_select 'textarea[name=?]', 'order[issue]', count: 0
		#issue shows on the page
		assert_select 'b', text: 'issue', count: 1
		assert_select 'span.error', text: "Feedback has been submitted", count: 1
		assert_select 'input[name=?]', 'solved', count: 1
		#other attributes cannot be changed
		assert_equal @order.total, @order.reload.total

		log_in_as @admin
		patch order_url(@order), admin_form: "1", order: { issue_status: "2" }
		assert_equal 2, @order.reload.issue_status
		assert_redirected_to user_orders_url(@admin)
		assert_not flash[:success].empty?

		log_in_as @user
		get order_url(@order)
		assert_select 'span.warning', text: "Issue is being resolved", count: 1
		
		patch order_url(@order), solved: 1
		assert_equal 3, @order.reload.issue_status
		assert_redirected_to order_url(@order)
		assert_not flash[:success].empty?
		follow_redirect!
		assert_select 'span.pending', text: "Issue has been resolved", count: 1
		assert_select 'div.ui.huge.heart.rating', count: 1
	end

	test 'valid update by admin' do
		log_in_as @admin
		get user_orders_url(@admin)
		assert_template 'orders/index/admin'

		assert_select 'span.success', text: "This order has no issue", count: 2
		assert_select 'textarea[name=?]', 'order[solution]', count: 0
		assert_select 'textarea[name=?]', 'order[note]', count: 2

		patch order_url(@order), order: { issue: "issue", satisfaction: 3 }
		assert_redirected_to user_orders_url(@admin)
		assert_not flash[:error].empty?
		assert_equal @order.satisfaction, @order.reload.satisfaction
		assert_equal @order.issue, @order.reload.issue

		log_in_as @user
		patch order_url(@order), order: { issue: "issue", satisfaction: 3 }
		assert_redirected_to order_url(@order)
		assert_not flash[:success].empty?
		assert_equal 3, @order.reload.satisfaction
		assert_equal "issue", @order.reload.issue

		log_in_as @admin
		get user_orders_url(@admin)
		assert_select 'span.success', text: "This order has no issue", count: 1
		assert_select 'span.error', text: "Feedback has been submitted", count: 1
		assert_select 'textarea[name=?]', 'order[solution]', count: 1
		assert_select 'textarea[name=?]', 'order[note]', count: 2
		
		patch order_url(@order), admin_form: "1", order: { issue_status: "2", solution: "hiii", note: "noteee", fulfillment_status: "1" }
		assert_redirected_to user_orders_url(@admin)
		assert_not flash[:success].empty?
		follow_redirect!

		assert_select 'span.error', text: "Feedback has been submitted", count: 0
		assert_select 'span.warning', text: "Solution has been offered", count: 1
		assert_select 'textarea[name=?]', 'order[solution]', text: "hiii", count: 1
		assert_select 'textarea[name=?]', 'order[note]', text: "noteee", count: 1
		assert_equal 1, @order.reload.fulfillment_status

		log_in_as @user
		patch order_url(@order), solved: "1"

		log_in_as @admin
		get user_orders_url(@admin)
		assert_select 'span.warning', text: "Solution has been offered", count: 0
		assert_select 'span.pending', text: "Issue has been resolved", count: 1
		assert_select 'textarea[name=?]', 'order[solution]', count: 1
		assert_select 'textarea[name=?]', 'order[note]', count: 2
	end	

	test 'invalid update' do
		log_in_as @user
		patch order_url(@order), order: { satisfaction: 6, issue: "a"*256 }
		assert_template 'orders/show'
		assert_equal "Error. Please limit your feedback to under 255 characters.", flash.now[:error]
	end	
end
