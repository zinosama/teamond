class OrderablesController < ApplicationController
	before_action :logged_in_user
	before_action :correct_user, only: [:update, :destroy]

	def index
		@items = []
		current_user.orderables.each do |orderable|
			if orderable.status == 0
				item = { orderable: orderable }
			elsif orderable.status == 1
				item = { orderable: orderable, msg: { msg: "Item info has changed!", class: "warning" } }
				flash.now[:warning] = "We have updated some item(s) in your cart. Please verify before purchasing."
			else
				if orderable.buyable.is_a? Dish
					item = { orderable: orderable, msg: { msg: "Item no longer available!", class: "error" } }
				else
					msg = orderable.buyable.milktea.active ? "One or more toppings is no longer available! You can remove highlighted topping below." : "Item no longer available!"
					item = { orderable: orderable, msg: { msg: msg, class: "error" } }
				end
				flash.now[:error] = "Some item(s) in your cart is no longer available. Please remove to continue."
			end
			@items.push(item)
		end

	end

	def create
		if params[:type] == "dish"
			buyable = Dish.find_by(id: params[:buyable_id])
			if buyable && buyable.active
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
		orderable = Orderable.find(params[:id])
		if params[:status]
			orderable.update_attribute(:status, 0) if orderable.status == 1
			redirect_to cart_url
		else
			if params[:orderable][:quantity] == "0"
				orderable.destroy
				redirect_and_flash(cart_url, :success, "Item removed")
			elsif orderable.update( quantity: params[:orderable][:quantity] )
				redirect_and_flash(cart_url, :success, "Quantity updated")
			else
				redirect_and_flash(cart_url, :error, "Quantity cannot be larger than 20")
			end
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
