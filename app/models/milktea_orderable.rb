class MilkteaOrderable < ActiveRecord::Base
	belongs_to :milktea
	has_one :orderable, as: :buyable
	
	has_many :addons_orderables, dependent: :destroy
	has_many :milktea_addons, through: :addons_orderables

	validates :milktea, presence: true
	validates :sweet_scale, presence: true, numericality: { less_than: 5, greater_than_or_equal_to: 0 }
	validates :temp_scale, presence: true, numericality: { less_than: 4, greater_than_or_equal_to: 0 }
	validates :size, presence: true, numericality: { less_than: 2, greater_than_or_equal_to: 0 }

	before_save :trim_addons

	def unit_price
		milktea.price + 0.99 * size.to_i + 0.5 * milktea_addons.size
	end

	private

	def trim_addons
		self.milktea_addon_ids = milktea_addon_ids.select{ |id| !id.blank? }
	end
end
