module Exceptions

	class InvalidBuyableForOrderableError < StandardError
		def initialize(msg = "Buyable is not a Dish and thus invalid in create action.")
			super
		end
	end
	
	class InactiveRecipeError < StandardError
		def initialize(msg = "Recipe is not active.")
			super
		end
	end
	
end