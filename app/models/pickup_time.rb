class PickupTime < ActiveRecord::Base
	validates :time, presence: true	
end
