class MilkteaAddonsController < ApplicationController

	def create
		@recipe = Recipe.new
		@dish_category = DishCategory.new
		@dish_categories = DishCategory.all

		@milktea_addon = MilkteaAddon.new(milktea_addon_params)
		if @milktea_addon.save
			flash[:success] = "New add-on saved."
			redirect_to manage_recipes_url
		else
			render 'shared/manage'
		end
	end

	private 

	def milktea_addon_params
		params.require(:milktea_addon).permit(:name, :price)
	end
end
