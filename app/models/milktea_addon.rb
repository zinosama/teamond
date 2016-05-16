class MilkteaAddon < ActiveRecord::Base
	include Propagatable
	validates :name, presence: true, length: { maximum: 50 }
	validates :price, presence: true, numericality: { greater_than: 0 }

	has_many :addons_orderables, dependent: :destroy
	has_many :milktea_orderables, through: :addons_orderables

	after_update :propagate_state_change
	after_update :propagate_price_change
end
