class RecipePolicy < ApplicationPolicy
  attr_reader :current_user, :recipe
  
  def initialize(current_user, model)
    @current_user = current_user
    @recipe = model
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
  
  def manage?
    @current_user.admin?
  end
end
