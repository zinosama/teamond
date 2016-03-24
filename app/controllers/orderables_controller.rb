class OrderablesController < ApplicationController
	before_action :logged_in_user
	before_action :correct_user, only: [:update, :destroy]

	def index
		@orderables = current_user.orderables
	end

	def create
		buyable_id = params[:buyable_id]
		if params[:type] == "dish"
			buyable = Dish.find_by(id: buyable_id)
			if buyable
				Orderable.create!(buyable: buyable, ownable: current_user, quantity: 1, unit_price: buyable.price)
				flash[:success] = "Item Added to Cart."
				redirect_to menu_url
			else
				flash[:error] = "Invalid Item. Please contact customer service for support."
				redirect_to menu_url
			end
		else
			flash[:error] = "Invalid request. Please contact customer service."
			redirect_to menu_url
		end
	end

	def update
		@orderable = Orderable.find(params[:id])
		if @orderable.update( quantity: params[:orderable][:quantity] )
			redirect_to cart_url
			flash[:success] = "Quantity updated."
		else
			redirect_to cart_url
			flash[:error] = "Quantity cannot be larger than 20"
		end
	end

	def destroy
		orderable = Orderable.find(params[:id])
		orderable.destroy
		redirect_to cart_url
		flash[:success] = "Item removed"
	end

	private 

	def correct_user
		orderable = Orderable.find(params[:id])
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
