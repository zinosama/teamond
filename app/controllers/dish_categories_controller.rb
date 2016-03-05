class DishCategoriesController < ApplicationController

	def create
		@recipe = Recipe.new
		@milktea_addon = MilkteaAddon.new
		@dish_categories = DishCategory.all

		@dish_category = DishCategory.new(dish_category_params)
		if @dish_category.save
			flash[:success] = "New category saved."
			redirect_to manage_recipes_url
		else
			render 'shared/manage'
		end
	end

	private

	def dish_category_params
		params.require(:dish_category).permit(:name, :description, :image)
	end
end
