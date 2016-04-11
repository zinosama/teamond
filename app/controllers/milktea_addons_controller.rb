class MilkteaAddonsController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin


	def create
		@recipe = Recipe.new
		@dish_category = DishCategory.new
		@dish_categories = DishCategory.all
		@addons = MilkteaAddon.all
		
		@milktea_addon = MilkteaAddon.new(milktea_addon_params)
		if @milktea_addon.save
			redirect_and_flash(manage_recipes_url, :success, "New add-on saved.")
		else
			render 'shared/manage'
		end
	end

	def edit
		@milktea_addon = MilkteaAddon.find(params[:id])
	end

	def update
		@milktea_addon = MilkteaAddon.find(params[:id])
		if @milktea_addon.update_attributes(milktea_addon_params)
			redirect_and_flash(manage_recipes_url, :success, "Add-on Updated")
		else
			render 'edit'
		end
	end

	private 

	def milktea_addon_params
		params.require(:milktea_addon).permit(:name, :price)
	end
end
