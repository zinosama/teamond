class OrderablesController < ApplicationController
	include ShopperValidations #contains valid_user
	before_action :logged_in_user
	before_action :valid_user, only: [:index, :create]
	before_action :valid_buyable, only: [:create]

	before_action :valid_orderable, only: [:update, :destroy]
	before_action :valid_quantity, only: [:update]

	after_action :verify_authorized, except: :index
	
	def index
		get_orderables
	end

	def create
		authorize Orderable
		if orderable = Orderable.find_by(buyable: @buyable, ownable: @shopper)
			orderable.increment!(:quantity)
		else
			Orderable.create!(buyable: @buyable, ownable: @shopper, unit_price: @buyable.price)
		end
		redirect_and_flash(menu_url, :success, "Item Added to Cart")
	rescue Exceptions::InvalidBuyableForOrderableError
		redirect_and_flash(menu_url, :error, "Invalid request. Please contact customer service")
	end

	def update
		authorize @orderable
		if params[:status]
			@orderable.active! if @orderable.updated?
			redirect_to shopper_cart_url(@orderable.ownable)
		else
			if @quantity <= 0
				@orderable.destroy
				redirect_and_flash(shopper_cart_url(@orderable.ownable), :success, "Item removed")
			else 
				@orderable.update_attribute(:quantity, @quantity)
				redirect_and_flash(shopper_cart_url(@orderable.ownable), :success, "Quantity updated")
			end
		end
	end

	def destroy
		authorize @orderable
		@orderable.destroy
		redirect_and_flash(shopper_cart_url(@orderable.ownable), :success, "Item removed")
	end

	private 

		def valid_buyable
			raise Exceptions::InvalidBuyableForOrderableError unless params[:type] == "dish"
			@buyable = Dish.find(params[:buyable_id])
			raise Exceptions::InactiveRecipeError unless @buyable.active
		rescue Exceptions::InvalidBuyableForOrderableError
			redirect_and_flash(menu_url, :error, "Invalid request. Please contact customer service")
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Invalid item. Please contact customer service")
		rescue Exceptions::InactiveRecipeError
			redirect_and_flash(menu_url, :error, "Inactive item. Please contact customer service")
		end

		def valid_orderable
			@orderable = Orderable.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Invalid request")
		end

		def valid_quantity
			shopper = @orderable.ownable
			@quantity = params[:orderable][:quantity].to_i if params[:orderable] && params[:orderable][:quantity]
			redirect_and_flash(shopper_cart_url(shopper), :error, "Quantity cannot be larger than 20") if (@quantity && @quantity > 20)
		end

		def get_orderables
			@items = []
			@shopper.orderables.each do |orderable|
				if orderable.active?
					@items << { orderable: orderable }
				elsif orderable.updated?
					@items << { orderable: orderable, msg: { msg: "Item info has changed!", class: "warning" } }
					flash.now[:warning] = "We have updated some item(s) in your cart. Please verify before purchasing."
				elsif orderable.inactive?
					if orderable.buyable.is_a? Dish
						@items << { orderable: orderable, msg: { msg: "Item no longer available!", class: "error" } }
					else
						msg = orderable.buyable.milktea.active ? "One or more toppings is no longer available! You can remove highlighted topping below." : "Item no longer available!"
						@items << { orderable: orderable, msg: { msg: msg, class: "error" } }
					end
					flash.now[:error] = "Some item(s) in your cart is no longer available. Please remove to continue."
				end
			end
		end

end
