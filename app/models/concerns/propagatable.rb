module Propagatable
  	
  private
	
		def propagate_state_change
			StatusPropagator.propagate_state_change(self)
		end
    
    def lazy_propagate_state_change
      propagate_state_change if active_changed?
    end
end
