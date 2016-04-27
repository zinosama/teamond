class Provider < ActiveRecord::Base
	has_one :user, as: :role
	belongs_to :store

	validates :user, presence: true
end
