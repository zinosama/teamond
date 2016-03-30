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
end
