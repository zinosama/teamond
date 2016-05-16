class DishCategory < ActiveRecord::Base
	include Propagatable
	has_many :dishes, dependent: :destroy
	
	validates :name, presence: true, length: { maximum: 50 }
	after_update :lazy_propagate_state_change

end
