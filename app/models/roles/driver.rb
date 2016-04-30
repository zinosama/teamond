class Driver < ActiveRecord::Base
	include Roleable

	has_many :orders
end
