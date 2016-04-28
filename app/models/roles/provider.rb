class Provider < ActiveRecord::Base
	has_one :user, as: :role
	belongs_to :store

	validates :store, presence: true
	validates :user, presence: true
end
