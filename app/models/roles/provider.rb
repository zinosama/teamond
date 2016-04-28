class Provider < ActiveRecord::Base
	has_one :user, as: :role
	belongs_to :store

end
