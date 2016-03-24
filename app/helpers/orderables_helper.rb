module OrderablesHelper

	def sum(orderables)
		sum = 0
		orderables.each{ |orderable| sum += orderable.unit_price * orderable.quantity }
		sum
	end

	def orderable_count(orderables)
		count = 0
		orderables.each{ |orderable| count += orderable.quantity }
		count
	end

end
