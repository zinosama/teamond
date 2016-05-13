class MilkteaAddon < ActiveRecord::Base
	validates :name, presence: true, length: { maximum: 50 }
	validates :price, presence: true, numericality: { greater_than: 0 }

	has_many :addons_orderables, dependent: :destroy
	has_many :milktea_orderables, through: :addons_orderables

	after_update :propagate_state_change
	
	def activate
		update_attribute(:active, true)
		propagate_state_change
		# self.milktea_orderables.each{ |milktea_orderable| milktea_orderable.orderable.to_modified_status if milktea_orderable.orderable }
	end

	def disable
		update_attribute(:active, false)
		# self.milktea_orderables.each{ |milktea_orderable| milktea_orderable.orderable.disable if milktea_orderable.orderable }
		propagate_state_change
	end
	
	private
	
		def propagate_state_change
			StatusPropagator.propagate_state_change(self)
		end
end
