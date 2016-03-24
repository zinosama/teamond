class OrdersController < ApplicationController
	before_action :logged_in_user
	before_action :cart_not_empty, only: [:new]

	def new
		@order = Order.new
	end

	private

	def cart_not_empty
		if current_user.orderables.empty?
			redirect_to menu_url
			flash[:error] = "Your cart is empty. Please add items before check out."
		end
	end


end
