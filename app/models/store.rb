class Store < ActiveRecord::Base
	has_many :providers
	
	validates :name, presence: true, length: { maximum: 50 }
	validates :address, presence: true, length: { maximum: 255 }
end
