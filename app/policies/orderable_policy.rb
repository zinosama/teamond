class OrderablePolicy < ApplicationPolicy
	attr_reader :current_user, :model

	def initialize(current_user, model)
		@current_user = current_user
		@model = model
	end

	def create?
		@current_user.shopper?
	end

	def update?
		@current_user.shopper? && @current_user.role == @model.ownable 
	end

	def destroy?
		@current_user.shopper? && @current_user.role == @model.ownable
	end

	class Scope < Struct.new(:user, :scope)
		def resolve
			items = []
			shopper = user.role
			shopper.orderables.each do |orderable|
				if orderable.status == 0
					items << { orderable: orderable }
				elsif orderable.status == 1
					items << { orderable: orderable, msg: { msg: "Item info has changed!", class: "warning" } }
					flash.now[:warning] = "We have updated some item(s) in your cart. Please verify before purchasing."
				else
					if orderable.buyable.is_a? Dish
						items << { orderable: orderable, msg: { msg: "Item no longer available!", class: "error" } }
					else
						msg = orderable.buyable.milktea.active ? "One or more toppings is no longer available! You can remove highlighted topping below." : "Item no longer available!"
						items << { orderable: orderable, msg: { msg: msg, class: "error" } }
					end
					flash.now[:error] = "Some item(s) in your cart is no longer available. Please remove to continue."
				end
			end
			items
		end
	end
	
end