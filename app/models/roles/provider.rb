class Provider < ActiveRecord::Base
	include Roleable
	
	validates :store, presence: true
	belongs_to :store
end
