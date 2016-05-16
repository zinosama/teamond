class Milktea < Recipe
	has_many :milktea_orderables
	validates :dish_category_id, absence: true

	#Caution! This hack may cause unexpected behaviors.
	#I'm unsure if model_name is used by Rails internal for other purposes. 
	#However, I'll go with it for now for its brevity.
	def self.model_name
		Recipe.model_name
	end
		
end