class MilkteaOrderablesController < ApplicationController
	before_action :logged_in_user

	def new
		@milktea = Milktea.find_by(id: params[:milktea_id])
		unless @milktea
			redirect_to menu_url
			flash[:error] = "Error loading selected milktea"
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
			render "new", id: @milktea
		end
	end

	private

	def milktea_orderable_params
		params.require(:milktea_orderable).permit(:sweet_scale, :temp_scale, :size, :milktea_id, milktea_addon_ids: [])
	end

end
