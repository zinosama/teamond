class MilkteaOrderable < ActiveRecord::Base
	include MilkteaOrderablePresentor
	belongs_to :milktea
	has_one :orderable, as: :buyable
	
	has_many :addons_orderables, dependent: :destroy
	has_many :milktea_addons, through: :addons_orderables

	enum sweet_scale: %i(unsweet little_sweet half_sweet less_sweet sweet)
	enum temp_scale: %i(chilled less_ice no_ice warm)
	enum size: %i(regular_size large_size)

	validates :milktea, presence: true
	validates :sweet_scale, presence: true
	validates :temp_scale, presence: true
	validates :size, presence: true

	before_save :trim_addons

	def unit_price
		milktea.price + (large_size? ? 0.99 : 0) + milktea_addons.map(&:price).sum
	end
	
	private

		def trim_addons
			self.milktea_addon_ids = milktea_addon_ids.select{ |id| !id.blank? }
		end
end
