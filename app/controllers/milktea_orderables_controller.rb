class MilkteaOrderablesController < ApplicationController
	include ShopperValidations #contains valid_user
	before_action :logged_in_user
	before_action :valid_milktea, only: [:new, :create]
	before_action :valid_user, only: [:create]
	
	before_action :valid_milktea_orderable, only: [:edit, :update]
	after_action :verify_authorized

	def new
		authorize MilkteaOrderable
		@milktea_orderable = MilkteaOrderable.new
	end

	def create
		authorize MilkteaOrderable
		@milktea_orderable = MilkteaOrderable.new(milktea_orderable_params)
		@milktea_orderable.milktea = @milktea
		if @milktea_orderable.save
			orderable = Orderable.create!(ownable: @shopper, buyable: @milktea_orderable, unit_price: @milktea_orderable.unit_price, quantity: 1)
			redirect_and_flash(menu_url, :success, "Milktea added to cart")
		else 
			render 'new'
		end
	end

	def edit
		authorize @milktea_orderable
		@milktea = @milktea_orderable.milktea
	end

	def update
		authorize @milktea_orderable
		if @milktea_orderable.update_attributes(milktea_orderable_params)
			@milktea_orderable.orderable.update_attribute(:unit_price, @milktea_orderable.unit_price)
			@milktea_orderable.orderable.to_modified_status(:skip_status_1_check)
			redirect_and_flash(shopper_cart_url(@milktea_orderable.orderable.ownable), :success, "Changes saved")
		else
			@milktea = @milktea_orderable.milktea
			render 'edit'
		end
	end

	private

		def milktea_orderable_params
			params.require(:milktea_orderable).permit(:sweet_scale, :temp_scale, :size, milktea_addon_ids: [])
		end

		def valid_milktea
			@milktea = Milktea.find(params[:milktea_id])
			raise Exceptions::InactiveRecipeError unless @milktea.active
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Invalid milktea. Please contact customer service")
		rescue Exceptions::InactiveRecipeError
			redirect_and_flash(menu_url, :error, "Inactive milktea. Please contact customer service")
		end

		def valid_milktea_orderable
			@milktea_orderable = MilkteaOrderable.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Invalid milktea item. Please contact customer service")
		end

end
