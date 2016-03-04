class Milktea < Recipe
	validates :dish_category_id, absence: true
end