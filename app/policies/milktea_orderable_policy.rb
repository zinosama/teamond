class MilkteaOrderablePolicy < ApplicationPolicy
	attr_reader :current_user, :model

	def initialize(current_user, model)
		@current_user = current_user
		@model = model
	end

	def new?
		@current_user.shopper?
	end

	def create?
		@current_user.shopper?
	end

	def edit?
		@current_user.shopper? && @current_user.role == @model.orderable.ownable
	end

	def update?
		@current_user.shopper? && @current_user.role == @model.orderable.ownable
	end
end