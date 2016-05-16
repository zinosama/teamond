class DishCategoryPolicy < ApplicationPolicy
  attr_reader :current_user, :dish_category
  
  def initialize(current_user, model)
    @current_user = current_user
    @dish_category = model
  end
  
  def create?
    @current_user.admin?
  end
  
  def edit?
    @current_user.admin?
  end
  
  def update?
    @current_user.admin?
  end
  
end
