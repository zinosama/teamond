class DishCategoriesController < ApplicationController
	before_action :logged_in_user
	before_action :valid_dish_category, only: [:edit, :update]
	
	def create
		authorize DishCategory
		@recipe = Recipe.new
		@milktea_addon = MilkteaAddon.new
		@dish_categories = DishCategory.all
		@addons = MilkteaAddon.all
		
		@dish_category = DishCategory.new(dish_category_params)
		@dish_category.save ? redirect_and_flash(manage_recipes_url, :success, "Category saved") : render('shared/manage')
	end

	def edit
		authorize DishCategory
	end

	def update
		authorize DishCategory
		@dish_category.update_attributes(dish_category_params) ?
			redirect_and_flash(manage_recipes_url, :success, "Category Updated") : 
			render('edit')
	end

	private

		def dish_category_params
			params.require(:dish_category).permit(:name, :active)
		end
		
		def valid_dish_category
			@dish_category = DishCategory.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Invalid category")	
		end
end
