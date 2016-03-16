class Orderable < ActiveRecord::Base
	belongs_to :ownable, :polymorphic => true
	belongs_to :buyable, :polymorphic => true
end
