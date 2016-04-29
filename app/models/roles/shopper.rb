class Shopper < ActiveRecord::Base
	include Roleable

	has_many :orders, dependent: :destroy
	has_many :orderables, as: :ownable, dependent: :destroy

	def item_count
		self.orderables.count
	end
end
