module StorePresentor
	def present_active
		active? ? "active" : "inactive" 
	end
end