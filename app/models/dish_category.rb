class DishCategory < ActiveRecord::Base
	has_many :dishes

	validates :name, presence: true, length: { maximum: 50 }
end
