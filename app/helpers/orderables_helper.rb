module OrderablesHelper

	def sum(orderables)
		sum = 0
		orderables.each{ |orderable| sum += orderable.unit_price * orderable.quantity }
		sum
	end

end
