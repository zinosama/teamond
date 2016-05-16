class Orderable < ActiveRecord::Base
	belongs_to :ownable, :polymorphic => true
	belongs_to :buyable, :polymorphic => true

	enum status: %i(active updated inactive)

	validates :quantity, presence: true, numericality: { less_than_or_equal_to: 20 }
	validates :unit_price, presence: true
	validates :buyable_id, presence: true
	validates :ownable_id, presence: true
	
	after_destroy :destroy_milktea

	def to_modified_status(args = nil)
		if buyable.is_a? MilkteaOrderable
			inactive_count = 0
			inactive_count += 1 unless buyable.milktea.active
			buyable.milktea_addons.each do |addon|
				inactive_count += 1 unless addon.active
			end
			if inactive_count == 0
				args == :skip_status_1_check ? active! : updated!
			end
		elsif buyable.is_a? Dish
			args == :skip_status_1_check ? active! : updated!
		end 
	end
	
	def recalculate_price
		new_price = buyable.unit_price
		update_attribute(:unit_price, new_price)
	end

	def disable
		inactive!
	end

	private 

	def destroy_milktea
		buyable.destroy if buyable.is_a? MilkteaOrderable	
	end
end
