module Propagatable
  	
  private
	
		def propagate_state_change
			Propagator.propagate_state_change(self)
		end
    
    def lazy_propagate_state_change
      propagate_state_change if active_changed?
    end
    
    def propagate_price_change
      Propagator.propagate_price_change(self) if price_changed?
    end
end
