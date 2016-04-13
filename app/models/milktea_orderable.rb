class MilkteaOrderable < ActiveRecord::Base
	belongs_to :milktea
	has_one :orderable, as: :buyable
	
	has_many :addons_orderables, dependent: :destroy
	has_many :milktea_addons, through: :addons_orderables

	validates :milktea, presence: true
	validates :sweet_scale, presence: true, numericality: { less_than: 5, greater_than_or_equal_to: 0 }
	validates :temp_scale, presence: true, numericality: { less_than: 4, greater_than_or_equal_to: 0 }
	validates :size, presence: true, numericality: { less_than: 2, greater_than_or_equal_to: 0 }
	validate :active_milktea

	before_save :trim_addons

	def unit_price
		milktea.price + 0.99 * size.to_i + 0.5 * milktea_addons.size
	end

	def display_sweet_scale
		scale = ["zero", "little", "half", "less", "regular"]
		scale[sweet_scale]
	end

	def display_temp_scale
		scale = ["chill", "less ice", "no ice", "warm"]
		scale[temp_scale]
	end

	def display_size
		scale = ["regular", "large"]
		scale[size]
	end

	private

	def active_milktea
		milktea = Milktea.find_by(id: self.milktea_id)
		errors.add(:milktea_id, "selected is not active.") unless milktea && milktea.active
	end

	def trim_addons
		self.milktea_addon_ids = milktea_addon_ids.select{ |id| !id.blank? }
	end
end
