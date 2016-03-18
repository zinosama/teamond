class OrderablesController < ApplicationController
	before_action :logged_in_user

	def index
		@orderables = current_user.orderables
	end

	def create
		buyable_id = params[:buyable_id]
		if params[:type] == "dish"
			buyable = Dish.find_by(id: buyable_id)
		end
		if buyable
			Orderable.create!(buyable: buyable, ownable: current_user, quantity: 1, unit_price: buyable.price)
			flash[:success] = "Item Added to Cart."
			redirect_to menu_url
		else
			flash[:error] = "Invalid Item. Please contact customer service for support."
			redirect_to menu_url
		end
	end

	def update
	end

	def destroy
	end

end
