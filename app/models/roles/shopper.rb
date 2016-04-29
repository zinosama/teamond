class Shopper < ActiveRecord::Base
	include Roleable

	has_many :orders, dependent: :destroy
	has_many :orderables, as: :ownable, dependent: :destroy
end
