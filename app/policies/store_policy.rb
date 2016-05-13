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
	
	def edit?
		@current_user.admin? || (@current_user.provider? && @current_user.role.store == @store)
	end
	
	def update?
		@current_user.admin? || (@current_user.provider? && @current_user.role.store == @store)
	end

	def permitted_attributes
		if @current_user.admin?
			[:name, :phone, :owner, :address, :active, :email, :website]
		elsif @current_user.provider?
			[:name, :phone, :owner, :address, :email, :website]
		end
	end
end