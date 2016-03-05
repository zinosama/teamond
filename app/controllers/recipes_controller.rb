class RecipesController < ApplicationController

	def manage #new
		@recipe = Recipe.new
		@dish_category = DishCategory.new
		@milktea_addon = MilkteaAddon.new
		@dish_categories = DishCategory.all
		render 'shared/manage'
	end

	def create
		@dish_category = DishCategory.new
		@milktea_addon = MilkteaAddon.new
		@dish_categories = DishCategory.all

		if params[:recipe][:type] == "dish"
			dish_category = DishCategory.find(params[:recipe][:dish_category_id])
			if dish_category
				@recipe = dish_category.dishes.build(recipe_params)
			else
				flash[:error] = "Error - Category Not Exist. Please contact site admin."
				render 'shared/manage'
				return
			end
		else
			@recipe= Recipe.new(recipe_params)
		end

		if @recipe.save
			flash[:success] = "New Item Saved."
			redirect_to manage_recipes_url
		else
			render 'shared/manage'
		end

	end

	private 

	def recipe_params
		params.require(:recipe).permit(:name, :description, :image, :price)
	end
end
