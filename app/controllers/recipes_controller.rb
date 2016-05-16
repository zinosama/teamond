class RecipesController < ApplicationController
	before_action :logged_in_user, except: [:show, :index]
	before_action :load_resources, only: [:manage, :create]
	before_action :valid_recipe, only: [:show, :edit, :update]

	after_action :verify_authorized, except: [:show, :index]
	
	def manage
		authorize Recipe
		@recipe = Recipe.new
		render 'shared/manage'
	end

	def index
		@dish_categories = DishCategory.all
		@milkteas = Milktea.active
	end

	def create
		authorize Recipe
		case params[:recipe][:type]
		when "Dish"
			@recipe = DishCategory.find(params[:recipe][:dish_category_id].to_i).dishes.build(recipe_params)
		when "Milktea"
			@recipe = Milktea.new(recipe_params)
		end
		raise Exceptions::InvalidRecipeTypeError if @recipe.nil?
		@recipe.save ? redirect_and_flash(manage_recipes_url, :success, "Item created") : render('shared/manage')
	rescue ActiveRecord::RecordNotFound
		@recipe = Recipe.new
		flash.now[:error] = "Invalid category"
		render 'shared/manage'
	rescue Exceptions::InvalidRecipeTypeError
		@recipe = Recipe.new
		flash.now[:error] = "Invalid type"
		render 'shared/manage'
	end

	def edit
		authorize Recipe
	end

	def update
		authorize Recipe
		if params[:recipe][:active]
			params[:recipe][:active] == "0" ? @recipe.disable : @recipe.activate
			redirect_and_flash(manage_recipes_url, :success, "Item updated")
		else #recipe now propagates status change via after_update callback
			@recipe.dish_category = DishCategory.find_by(id: params[:recipe][:dish_category_id]) if @recipe.is_a? Dish
			@recipe.update_attributes(recipe_params) ? redirect_and_flash(manage_recipes_url, :success, "Item updated") : render('edit')
		end
	end

	def show
	end 

	private 

	def recipe_params
		params.require(:recipe).permit(:name, :description, :image, :price, :store_id)
	end
	
	def valid_recipe
		@recipe = Recipe.find(params[:id])
	rescue ActiveRecord::RecordNotFound
		redirect_and_flash(menu_url, :error, "Invalid item")
	end
	
	def load_resources
		@dish_category = DishCategory.new
		@milktea_addon = MilkteaAddon.new
		@dish_categories = DishCategory.all
		@addons = MilkteaAddon.all
	end
end
