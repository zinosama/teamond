class DishCategoriesController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin

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

	def edit
		@dish_category = DishCategory.find(params[:id])
	end

	def update
		@dish_category = DishCategory.find(params[:id])
		if @dish_category && @dish_category.update_attributes(dish_category_params)
			flash[:success] = "Category Updated."
			redirect_to manage_recipes_url
		else
			render 'edit'
		end 
	end

	def destroy
		dish_category = DishCategory.find(params[:id])
		dish_category.destroy
		flash[:success] = "Category Deleted."
		redirect_to manage_recipes_url
	end

	private

	def dish_category_params
		params.require(:dish_category).permit(:name, :description, :image)
	end
end
