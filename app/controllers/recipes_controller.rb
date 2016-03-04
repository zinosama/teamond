class RecipesController < ApplicationController

	def manage #new
		@recipe = Recipe.new
		@dish_category = DishCategory.new
		@milktea_addon = MilkteaAddon.new
	end


end
