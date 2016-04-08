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
		self.created_at.utc.in_time_zone("Eastern Time (US & Canada)").strftime("%B %e, %Y (%A)")
	end	

	def create_time_to_min
		self.created_at.utc.in_time_zone("Eastern Time (US & Canada)").strftime("%H : %M, %B %e, %Y (%A)")
	end

	def num_of_items
		self.orderables.count
	end

	def decode_satisfaction
		rating = self.satisfaction
		if rating == 0
			"Unrated"
		elsif rating == 1
			"Worst"
		elsif rating == 2
			"Bad"
		elsif rating == 3
			"Average"
		elsif rating == 4
			"Above average"
		elsif rating == 5
			"Best"
		end				
	end

	def decode_issue_status(source)
		status = self.issue_status
		if status == 0
			{ msg: "This order has no issue", status: :success }
		elsif status == 1
			{ msg: "Feedback has been submitted", status: :error }
		elsif status == 2
			{ msg: (source == :admin ? "Solution has been offered" : "Issue is being resolved"), status: :warning }
		elsif status == 3
			{ msg: "Issue has been resolved", status: :pending }
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
			{ msg: "Order received", status: :pending }
		elsif status == 1
			{ msg: "Order delivered", status: :success }
		end
	end

end
