class PickupLocation < ActiveRecord::Base
	has_many :locations_times, dependent: :destroy
	has_many :pickup_times, through: :locations_times

	validates :name, presence: true, length: { maximum: 50 }
	validates :address, presence: true, length: { maximum: 255 }
	validates :description, length: { maximum: 255 }

	def valid_associations
		current_time = Time.now.utc.in_time_zone("Eastern Time (US & Canada)")
		get_valid_associations(current_time)
	end

	def get_valid_associations(current_time)
		current_day = current_time.strftime("%w").to_i
		current_hr = current_time.strftime("%k").to_i
		current_min = current_time.strftime("%M").to_i
		valid_associations = []
		self.locations_times.where( day_of_week: [ current_day, next_day(current_day) ] ).each do |location_time|
			location_time.join_by_pickup_time(valid_associations) if location_time.before_cutoff?(current_day, current_hr, current_min)
		end
	end

	private 

	def next_day(current_day)
		(current_day + 1) % 7
	end
end
