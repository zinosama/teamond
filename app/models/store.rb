class Store < ActiveRecord::Base
	include StorePresentor
	has_many :providers
	
	validates :name, presence: true, length: { maximum: 50 }
	validates :phone, presence: true, length: { maximum: 20 }
	validates :owner, presence: true, length: { maximum: 255 }
	validates :address, presence: true, length: { maximum: 255 }
	# validates :lat, presence: true
	# validates :long, presence: true

	#optional attributes
	validates :email, length: { maximum: 255 }
	validates :website, length: { maximum: 255 }
	
	before_create :default_lat_long #placeholder for lat and long

	private

		def default_lat_long
			self.lat = 0 if lat.nil?
			self.long = 0 if long.nil?
		end
end
