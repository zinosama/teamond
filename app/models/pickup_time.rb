class PickupTime < ActiveRecord::Base
	has_many :locations_times
	has_many :pickup_locations, through: :locations_times

	validates :pickup_hour, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
	validates :pickup_minute, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }
	validates :cutoff_hour, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
	validates :cutoff_minute, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59}

	def pickup_time
		"#{self.pickup_hour} : #{self.pickup_minute}"
	end	
end
