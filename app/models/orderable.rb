class Orderable < ActiveRecord::Base
	belongs_to :ownable, :polymorphic => true
	belongs_to :buyable, :polymorphic => true

	validates :quantity, presence: true, numericality: { less_than_or_equal_to: 20 }
	validates :unit_price, presence: true
	validates :buyable_id, presence: true
	validates :ownable_id, presence: true
	validates :status, presence: true, numericality: true
	
	after_destroy :destroy_milktea

	def to_modified_status(args = nil)
		if buyable.is_a? MilkteaOrderable
			inactive_count = 0
			inactive_count += 1 unless buyable.milktea.active
			buyable.milktea_addons.each do |addon|
				inactive_count += 1 unless addon.active
			end
			if inactive_count == 0
				args == :skip_status_1_check ? update_attribute(:status, 0) : update_attribute(:status, 1)
			end
		elsif buyable.is_a? Dish
			args == :skip_status_1_check ? update_attribute(:status, 0) : update_attribute(:status, 1)
		end 
	end

	def disable
		self.update_attribute(:status, 2)
	end

	private 

	def destroy_milktea
		buyable.destroy if buyable.is_a? MilkteaOrderable	
	end
end
