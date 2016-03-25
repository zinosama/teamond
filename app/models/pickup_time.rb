class PickupTime < ActiveRecord::Base
	validates :pickup_hour, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
	validates :pickup_minute, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }
	validates :cutoff_hour, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
	validates :cutoff_minute, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59}

end
