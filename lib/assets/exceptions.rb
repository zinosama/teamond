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
	
	class InactiveDeliveryLocationError < StandardError
		def initialize(msg = "Delivery location is not active.")
			super
		end
	end

	class InvalidRecipientInfoError < StandardError
		def initialize(msg = "Invalid recipient info.")
			super
		end
	end

 	class InvalidOrderAttrsError < StandardError
 		def initialize(msg = "Invalid Order Attributes.")
 			super
		end
 	end

	class OnlinePaymentError < StandardError
		def initialize(msg = "Online payment error.")
			super
		end
	end
	
	class InvalidRecipeTypeError < StandardError
		def initialize(msg = "Invalid Recipe Type.")
			super
		end
	end
	
end