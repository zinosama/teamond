class LocationsTime < ActiveRecord::Base
	DOWs = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	belongs_to :pickup_time
	belongs_to :pickup_location
	has_many :orders

	validates :day_of_week, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
	validates :pickup_time, presence: true
	validates :pickup_location, presence: true

	def before_cutoff?(current_day, current_hr, current_min)
		current_day == self.day_of_week ? valid_for_today?(current_hr, current_min) : true
	end

	def associated_pickup_time
		"#{self.pickup_time.pickup_time} - #{DOWs[day_of_week]}"
	end

	def join_by_pickup_time(collection)
		collection.each_with_index do |locations_time, index|
			that_hour = locations_time.pickup_time.pickup_hour
			that_minute = locations_time.pickup_time.pickup_minute
			that_day = locations_time.day_of_week
		 	if earlier_by_day(that_day) || earlier_by_hour(that_day, that_hour) || earlier_by_min(that_day, that_hour, that_minute)
				collection.insert(index, self)
				return
			end
		end

		collection.push self
	end

	private

	def earlier_by_hour(that_day, that_hour)
		(self.day_of_week == that_day) && (self.pickup_time.pickup_hour < that_hour)
	end

	def earlier_by_min(that_day, that_hour, that_minute)
		(self.day_of_week == that_day) && (self.pickup_time.pickup_hour == that_hour) && (self.pickup_time.pickup_minute < that_minute)
	end

	def earlier_by_day(that_day)
		(self.day_of_week + 1) % 7 == that_day % 7
	end

	def valid_for_today?(current_hr, current_min)
		time = self.pickup_time
		if current_hr < time.cutoff_hour
			true
		elsif current_hr == time.cutoff_hour
			current_min <= time.cutoff_minute
		else
			false
		end
	end

end
