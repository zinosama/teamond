class Provider < ActiveRecord::Base
	has_one :user, as: :role
	
	validates :user, presence: true
end
