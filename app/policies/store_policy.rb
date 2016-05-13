class StorePolicy < ApplicationPolicy
	attr_reader :current_user, :model

	def initialize(current_user, model)
		@current_user = current_user
		@store = model
	end

	def new?
		@current_user.admin?
	end

	def create?
		@current_user.admin?
	end

	def show?
		@current_user.admin? || (@current_user.provider? && @current_user.role.store == @store)
	end

	def permitted_attributes
		[:name, :phone, :owner, :address, :active, :email, :website]
	end
end