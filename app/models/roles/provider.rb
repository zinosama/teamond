class Provider < ActiveRecord::Base
	include Roleable
	
	validates :store, presence: true
	belongs_to :store

	def name
		user.name
	end
end
