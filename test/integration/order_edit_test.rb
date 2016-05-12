require 'test_helper'

class OrderEditTest < ActionDispatch::IntegrationTest

	def setup
		@shopper = users(:ed)
		@admin = users(:zino)
		@order = orders(:two)
	end

	test 'valid update by user' do
		log_in_as @shopper 
		get order_url(@order)
		assert_template 'orders/show'

		assert @order.no_feedback?
		assert_select 'div.ui.huge.heart.rating', count: 1
		assert_select 'textarea[name=?]', 'order[issue]', count: 1
		assert_select 'span.success', text: "This order has no feedback", count: 1

		patch order_url(@order), order: { total: 301, satisfaction: "3", issue: "issue" }
		assert_redirected_to order_url(@order)
		assert_not flash[:success].empty?
		follow_redirect!
		assert_template 'orders/show'

		#record has been updated
		assert @order.reload.indifferent?
		assert_equal "issue", @order.reload.issue
		assert @order.reload.feedback_created?

		#view has changed after issue is submitted
		assert_select 'div.ui.huge.heart.rating', count: 0
		assert_select 'textarea[name=?]', 'order[issue]', count: 0
		#issue shows on the page
		assert_select 'b', text: 'issue', count: 1
		assert_select 'span.error', text: "Feedback has been submitted", count: 1
		assert_select 'input[name=?]', 'solved', count: 1
		#other attributes cannot be changed
		assert_equal @order.total, @order.reload.total

		patch order_url(@order), solved: 1
		assert @order.reload.feedback_resolved?
		assert_redirected_to order_url(@order)
		assert_not flash[:success].empty?
		follow_redirect!
		assert_select 'span.pending', text: "Feedback has been answered", count: 1
		assert_select 'div.ui.huge.heart.rating', count: 1
	end

	test 'valid update by admin' do
		log_in_as @admin
		get admin_orders_url(@admin.role)
		assert_template 'orders/index/admin'

		assert_select 'span.success', text: "This order has no feedback", count: 2
		assert_select 'textarea[name=?]', 'order[solution]', count: 0
		assert_select 'textarea[name=?]', 'order[note]', count: 2

		#admin cannot update issue and satisfaction
		assert @order.no_feedback?
		patch order_url(@order), order: { issue: "issue", satisfaction: "3" }
		assert_redirected_to admin_orders_url(@admin.role)
		assert_not flash[:success].empty?
		assert_equal @order.satisfaction, @order.reload.satisfaction
		assert_equal @order.issue, @order.reload.issue
		assert @order.reload.no_feedback?

		#user submits an issue, which changes issue status to 1
		log_in_as @shopper
		patch order_url(@order), order: { issue: "issue", satisfaction: "3" }
		assert_not flash[:success].empty?
		follow_redirect!
		assert @order.reload.feedback_created?

		#check index page again
		log_in_as @admin
		get admin_orders_url(@admin.role)
		assert_select 'span.success', text: "This order has no feedback", count: 1
		assert_select 'span.error', text: "Feedback has been submitted", count: 1
		assert_select 'textarea[name=?]', 'order[solution]', count: 1
		assert_select 'textarea[name=?]', 'order[note]', count: 2
		
		#change other allowed properties as admin
		patch order_url(@order), order: { solution: "hiii", note: "noteee", fulfillment_status: "confirmed" }
		assert_redirected_to admin_orders_url(@admin.role)
		assert_not flash[:success].empty?
		follow_redirect!

		#verify the properties have been changed
		assert_select 'span.error', text: "Feedback has been submitted", count: 1
		assert_select 'textarea[name=?]', 'order[solution]', text: "hiii", count: 1
		assert_select 'textarea[name=?]', 'order[note]', text: "noteee", count: 1
		assert @order.reload.confirmed?

		#resolve the issue as user
		log_in_as @shopper
		patch order_url(@order), solved: "1"

		#see issue being resolved from admin's view
		log_in_as @admin
		get admin_orders_url(@admin.role)
		assert_select 'span.pending', text: "Feedback has been answered", count: 1
		assert_select 'textarea[name=?]', 'order[solution]', count: 1
		assert_select 'textarea[name=?]', 'order[note]', count: 2
	end	

	test 'invalid update' do
		log_in_as @shopper
		patch order_url(@order), order: { satisfaction: 6, issue: "a"*256 }
		assert_template 'orders/show'
		assert_equal "Error saving your satisfaction rating, please try again", flash.now[:error]

		log_in_as @admin
		patch order_url(@order), order: { note: "a"*256, solution: "a"*256 }
		assert_template 'orders/show'
		assert_equal "Error! Please limit your input to under 255 characters", flash.now[:error]
	end	

end
