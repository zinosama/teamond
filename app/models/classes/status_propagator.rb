class StatusPropagator
  
  #assumes and propagates state changes based obj's current state
  def self.propagate_state_change(obj)
    target_state = obj.active? ? :to_modified_status : :disable 
    
    case obj
    when Dish 
      obj.orderables.each(&target_state)
    when Milktea, MilkteaAddon
      obj.milktea_orderables.map(&:orderable).each(&target_state)
    when Store
      target_state = :activate if target_state == :to_modified_status
      obj.recipes.each(&target_state)
    end  
  
  end
  
end