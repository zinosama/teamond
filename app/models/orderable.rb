class Orderable < ActiveRecord::Base
	belongs_to :ownable, :polymorphic => true
	belongs_to :buyable, :polymorphic => true

	validates :quantity, presence: true, numericality: { less_than_or_equal_to: 20 }
	validates :unit_price, presence: true
	validates :buyable_id, presence: true
	validates :ownable_id, presence: true
end