class PickupLocation < ActiveRecord::Base
	has_many :locations_times, dependent: :destroy
	has_many :pickup_times, through: :locations_times

	validates :name, presence: true, length: { maximum: 50 }
	validates :address, presence: true, length: { maximum: 255 }
	validates :description, length: { maximum: 255 }
end
