class Order < ActiveRecord::Base
	belongs_to :user
	has_many :orderables, as: :ownable
	belongs_to :locations_time

	validates :total, presence: true, numericality: { greater_than: 0 }
	validates :payment_method, presence: true, numericality: { less_than_or_equal_to: 1, greater_than_or_equal_to: 0 }
	validates :recipient_name, presence: true, length: { maximum: 50 }
	validates :recipient_phone, presence: true, length: { maximum: 60 }
	validates :recipient_wechat, length: { maximum: 50 }
	validates :locations_time, presence: true
	validates :user, presence: true
	validates :satisfaction, numericality: { less_than_or_equal_to: 5, greater_than_or_equal_to: 0 }
	validates :issue, length: { maximum: 255 }


	def paying_cash?
		self.payment_method == 1
	end

	def create_time
		self.created_at.strftime("%B %e, %Y (%A)")
	end	

	def num_of_items
		self.orderables.count
	end

	def decode_issue_status
		status = self.issue_status
		if status == 0
			{ msg: "This order has no issue", status: :pending }
		elsif status == 1
			{ msg: "An issue has been raised", status: :error }
		elsif status == 2
			{ msg: "Issue has been resolved", status: :warning }
		elsif status == 3
			{ msg: "Issue has been closed", status: :pending }
		end				
	end

	def decode_payment_status
		status = self.payment_status
		if status == 0
			"Not received"
		elsif status == 1
			"Received"
		elsif status == 2			
			"Refunded"
		end
	end

	def decode_payment_method
		code = self.payment_method
		if code == 0
			"Online payment"
		else
			"Cash payment"
		end
	end

	def decode_fulfillment_status
		status = self.fulfillment_status
		if status == 0
			{ msg: "Order received", status: :success }
		elsif status == 1
			{ msg: "Order delivered", status: :pending }
		elsif status == 2
			{ msg: "An issue has been reported. We're working on it!", status: :error }
		else
			{ msg: "Your issue has been resolved", status: :warning }
		end
	end

end
