class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :model
  
  def initialize(current_user, model)
    @current_user = current_user
    @model = model
  end
  
  def new?
    @current_user.nil? || @current_user.admin?
  end
  
  def create?
    @current_user.nil? || @current_user.admin?
  end
  
  def edit?
    @current_user.admin? || @current_user == @model
  end
  
  def update?
    @current_user.admin? || @current_user == @model
  end
  
  def index?
    @current_user.admin?
  end
  
  def permitted_attributes
    if @current_user.nil?
      [ :name, :email, :phone, :wechat, :password, :password_confirmation ]
    elsif @current_user.admin?
      [ :name, :email, :phone, :wechat, :password, :password_confirmation, :role_type, role_attributes: [:store_id] ]
    end
  end
end
