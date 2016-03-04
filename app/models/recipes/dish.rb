class Dish < Recipe
	belongs_to :dish_category
	
	validates :dish_category, presence: true

end