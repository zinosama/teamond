class DishCategory < ActiveRecord::Base
	has_many :dishes, dependent: :destroy

	validates :name, presence: true, length: { maximum: 50 }
end
