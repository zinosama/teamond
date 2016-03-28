class PickupTime < ActiveRecord::Base
	has_many :locations_times, dependent: :destroy
	has_many :pickup_locations, through: :locations_times

	validates :pickup_hour, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
	validates :pickup_minute, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }
	validates :cutoff_hour, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
	validates :cutoff_minute, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59}

	def pickup_time
		format_time(self.pickup_hour, self.pickup_minute)
	end	

	def cutoff_time
		format_time(self.cutoff_hour, self.cutoff_minute)
	end

	private 

	def format_time(hour, minute)
		formated_hour = "%02d" % hour
		formated_minute = "%02d" % minute
		"#{formated_hour} : #{formated_minute}"
	end
end
