class Order < ActiveRecord::Base
	include OrderPresentor

	belongs_to :shopper
	belongs_to :driver
	has_many :orderables, as: :ownable, dependent: :destroy

	enum satisfaction: %i(unrated worst bad indifferent good best)
	enum issue_status: %i(no_feedback feedback_created feedback_resolved)
	enum payment_status: %i(unpaid paid refunded)
	enum payment_method: %i(online cash)
	enum fulfillment_status: %i(received confirmed denied in_transit arrived delivered cancelled)
	#raise ArgumentError when value passed in is string or not included in the hash

	validates :total, presence: true, numericality: { greater_than: 0 }
	validates :recipient_name, presence: true, length: { maximum: 50 }
	validates :recipient_phone, presence: true, length: { maximum: 60 }
	validates :recipient_wechat, length: { maximum: 50 }
	validates :delivery_location, presence: true
	validates :delivery_time, presence: true
	validates :shopper, presence: true
	validates :issue, length: { maximum: 255 }
	validates :solution, length: { maximum: 255 }
	validates :note, length: { maximum: 255 }
	validates :payment_method, presence: true

	before_save :update_issue_status

	def self.get_query(query_param)
		case query_param
		when "unpaid"
			{ payment_status: 0 }
		when "unfulfilled"
			{ fulfillment_status: 0 }
		when "fulfilled"
			{ fulfillment_status: 1 }
		when "complained"
			{ issue_status: 1 }
		when "resolved"
			{ issue_status: 2 }
		end
	end

	def create_time
		self.created_at.utc.in_time_zone("Eastern Time (US & Canada)").strftime("%B %e, %Y (%A)")
	end	

	def create_time_to_min
		self.created_at.utc.in_time_zone("Eastern Time (US & Canada)").strftime("%H : %M, %B %e, %Y (%A)")
	end

	def delivery_time_to_min
		self.delivery_time.in_time_zone("Eastern Time (US & Canada)").strftime("%H : %M, %B %e, %Y (%A)")
	end

	def item_count
		self.orderables.count
	end

	private

		def update_issue_status
			feedback_created! if no_feedback? && !(issue.nil? || issue.empty?)
		end

end
