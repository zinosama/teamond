class MilkteaOrderablesController < ApplicationController
	before_action :logged_in_user
	before_action :correct_user, only: [:edit, :update]

	def new
		@milktea = Milktea.find_by(id: params[:milktea_id])
		unless @milktea && @milktea.active
			redirect_and_flash(menu_url, :error, "Error loading selected milktea")
		end
		@milktea_orderable = MilkteaOrderable.new
	end

	def create
		@milktea_orderable = MilkteaOrderable.new(milktea_orderable_params)
		if @milktea_orderable.save
			orderable = Orderable.new(ownable: current_user, buyable: @milktea_orderable, unit_price: @milktea_orderable.unit_price, quantity: 1)
			redirect_to menu_url
			if orderable.save	
				flash[:success] = "Milktea Added to Cart"
			else
				flash[:error] = "Error! Please login again. Contact customer service if error persists!"
			end
		else
			@milktea = Milktea.find_by(id: params[:milktea_orderable][:milktea_id])
			if @milktea && @milktea.active
				render "new"
			else
				redirect_and_flash(menu_url, :error, "Invalid milktea submitted")
			end
		end
	end

	def edit
		@milktea_orderable = MilkteaOrderable.find_by(params[:id])
		unless @milktea_orderable
			redirect_to menu_url
			flash[:error] = "Unidentified item"
		end
		@milktea = @milktea_orderable.milktea
	end

	def update
		@milktea_orderable = MilkteaOrderable.find(params[:id])
		if @milktea_orderable.update_attributes(milktea_orderable_params)
			@milktea_orderable.orderable.update_attribute(:unit_price, @milktea_orderable.unit_price)
			redirect_to cart_url
			flash[:success] = "Changes saved"
		else
			@milktea = @milktea_orderable.milktea
			render 'edit'
		end
	end

	private

	def milktea_orderable_params
		params.require(:milktea_orderable).permit(:sweet_scale, :temp_scale, :size, :milktea_id, milktea_addon_ids: [])
	end

	def correct_user
		orderable = MilkteaOrderable.find(params[:id]).orderable
		if orderable.ownable.is_a? User
			user = orderable.ownable
			unless user == current_user
				redirect_to cart_url
				flash[:error] = "Unauthorized request"
			end
		else
			redirect_to cart_url
			flash[:error] = "Unauthorized request."
		end
	end

end
