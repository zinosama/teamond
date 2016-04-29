class OrderablePolicy < ApplicationPolicy
	attr_reader :current_user, :model

	def initialize(current_user, model)
		@current_user = current_user
		@user = model
	end

	def create?
		@current_user.shopper?
	end
	
end