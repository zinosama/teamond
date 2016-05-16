class MilkteaAddonsController < ApplicationController
	before_action :logged_in_user
	before_action :validate_milktea_addon, only: [:edit, :update]

	def create
		authorize MilkteaAddon
		load_resources		
		@milktea_addon = MilkteaAddon.new(milktea_addon_params)
		@milktea_addon.save ? redirect_and_flash(manage_recipes_url, :success, "Addon saved") : render('shared/manage')
	end

	def edit
		authorize MilkteaAddon
	end

	def update
		authorize MilkteaAddon
		@milktea_addon.update_attributes(milktea_addon_params) ?
			redirect_and_flash(manage_recipes_url, :success, "Add-on Updated") :
			render('edit')
	end

	private 

		def milktea_addon_params
			params.require(:milktea_addon).permit(:name, :price, :active)
		end
		
		def validate_milktea_addon
			@milktea_addon = MilkteaAddon.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Invalid milktea addon")
		end
		
		def load_resources
			@recipe = Recipe.new
			@dish_category = DishCategory.new
			@dish_categories = DishCategory.all
			@addons = MilkteaAddon.all
		end
end
