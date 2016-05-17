module MilkteaOrderablePresentor
  
  def display_sweet_scale
    sweet_scale.to_s.humanize
	end

	def display_temp_scale
	  temp_scale.to_s.humanize
  end

	def display_size
		size.to_s.humanize
	end
  
end
