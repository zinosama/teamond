class Dish < Recipe
	belongs_to :dish_category
	has_many :orderables, as: :buyable

	validates :dish_category, presence: true

	#Caution! This hack may cause unexpected behaviors.
	#I'm unsure if model_name is used by Rails internal for other purposes. 
	#However, I'll go with it for now for its brevity.
	def self.model_name
		Recipe.model_name
	end

	def update_associated_orderables(status)
		if status == :active || status == :modified
			self.orderables.update_all(status: 1)
		else
			self.orderables.update_all(status: 2)
		end
	end

end