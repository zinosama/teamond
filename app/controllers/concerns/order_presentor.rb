module OrderPresentor

	def present_fulfillment_status
		if received?
			{ msg: "Order received", klass: :pending }
		elsif confirmed?
			{ msg: "Order confirmed", klass: :confirmed }
		elsif denied?
			{ msg: "Store denied", klass: :error }
		elsif in_transit?
			{ msg: "Order in transit", klass: :warning }
		elsif arrived?
			{ msg: "Order arrived", klass: :success }
		elsif delivered?
			{ msg: "Order delivered", klass: :success }
		elsif cancelled?
			{ msg: "Order cancelled", klass: :error }
		end
	end

	def present_issue_status
		if no_feedback?
			{ msg: "This order has no feedback", klass: :success }
		elsif feedback_created?
			{ msg: "Feedback has been submitted", klass: :error }
		elsif feedback_resolved?
			{ msg: "Feedback has been answered", klass: :pending }
		end				
	end

	def num_satisfaction
		Order.satisfactions[satisfaction]
	end
end