class MilkteaAddonPolicy < ApplicationPolicy
  attr_reader :current_user, :milktea_addon
  
  def initialize(current_user, model)
    @current_user = current_user
    @milktea_addon = model
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
