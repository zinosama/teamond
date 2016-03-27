class LocationsTime < ActiveRecord::Base
	belongs_to :pickup_time
	belongs_to :pickup_location

	validates :day_of_week, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
	validates :pickup_time, presence: true
	validates :pickup_location, presence: true
end
