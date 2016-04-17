class MilkteaAddon < ActiveRecord::Base
	validates :name, presence: true, length: { maximum: 50 }
	validates :price, presence: true, numericality: { greater_than: 0 }

	has_many :addons_orderables, dependent: :destroy
	has_many :milktea_orderables, through: :addons_orderables

	def activate
		self.update_attribute(:active, true)
		self.milktea_orderables.each{ |milktea_orderable| milktea_orderable.orderable.to_modified_status }
	end

	def disable
		self.update_attribute(:active, false)
		self.milktea_orderables.each{ |milktea_orderable| milktea_orderable.orderable.disable }
	end
end
