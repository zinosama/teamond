class RecipesController < ApplicationController
	before_action :logged_in_user, except: [:show, :index]
	before_action :logged_in_admin, except: [:show, :index]

	def manage
		@recipe = Recipe.new
		@dish_category = DishCategory.new
		@milktea_addon = MilkteaAddon.new
		@dish_categories = DishCategory.all
		@addons = MilkteaAddon.all
		render 'shared/manage'
	end

	def index
		@dish_categories = DishCategory.all
		@milkteas = Milktea.where("active = ?", true)
	end

	def create
		@dish_category = DishCategory.new
		@milktea_addon = MilkteaAddon.new
		@dish_categories = DishCategory.all
		@addons = MilkteaAddon.all
		
		if params[:recipe][:type] == "Dish"
			dish_category = DishCategory.find_by(id: params[:recipe][:dish_category_id])
			if dish_category
				@recipe = dish_category.dishes.build(recipe_params)
			else
				@recipe = Recipe.new
				flash.now[:error] = "Error - Category Not Exist. Please contact site admin."
				render 'shared/manage'
				return
			end
		elsif params[:recipe][:type] == "Milktea"
			@recipe= Milktea.new(recipe_params)
		else
			@recipe = Recipe.new(recipe_params)
		end
		if @recipe.save
			flash[:success] = "New Item Saved."
			redirect_to manage_recipes_url
		else
			render 'shared/manage'
		end
	end

	def edit
		@recipe = Recipe.find(params[:id])
	end

	def update
		@recipe = Recipe.find(params[:id])
		if params[:recipe][:active]
			params[:recipe][:active] == "0" ? @recipe.update_attribute(:active, false) : @recipe.update_attribute(:active, true)
			redirect_and_flash(manage_recipes_url, :success, "Menu item updated")
		else
			if @recipe.type == "Dish"
				dish_category = DishCategory.find_by(id: params[:recipe][:dish_category_id])
				@recipe.dish_category = dish_category if dish_category
			end
			@recipe.update_attributes(recipe_params) ? redirect_and_flash(manage_recipes_url, :success, "Menu item updated") : render('edit')
		end
	end

	def show 
		@recipe = Recipe.find_by(id: params[:id])
		redirect_to(menu_url, :error, "Cannot find menu item") unless @recipe
	end 

	private 

	def recipe_params
		params.require(:recipe).permit(:name, :description, :image, :price)
	end
end
