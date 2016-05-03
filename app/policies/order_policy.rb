class OrderPolicy < ApplicationPolicy
	attr_reader :current_user, :model

	def initialize(current_user, model)
		@current_user = current_user
		@model = model
	end

	def show?
		@current_user.role == @order.shopper || @current_user.admin?
	end

	def update?
		@current_user.role == @order.shopper || @current_user.admin? || @current_user.driver?
	end

	def permitted_update_attributes
		if @current_user.admin?
			[:fulfillment_status, :solution, :note, :payment_status]
		elsif @current_user.shopper?
			[:satisfaction]
		elsif @current_user.driver?
			[:fulfillment_status]
		end
	end

end