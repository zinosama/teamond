class Order < ActiveRecord::Base
	belongs_to :user
	has_many :orderables, as: :ownable
end
