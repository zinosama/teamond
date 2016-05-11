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
	
end