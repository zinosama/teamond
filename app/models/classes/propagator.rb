class Propagator
  
  #assumes and propagates state changes based obj's current state
  def self.propagate_state_change(obj)
    if obj.is_a? MilkteaOrderable
      obj.orderable.to_modified_status(:skip_status_1_check)
    else 
      target_state = obj.active? ? :to_modified_status : :disable 
      case obj
      when Dish 
        obj.orderables.each(&target_state)
      when Milktea, MilkteaAddon
        obj.milktea_orderables.map(&:orderable).each(&target_state) unless obj.milktea_orderables.empty?
      when Store
        #Only disabling store will be propagated to associated recipes
        obj.recipes.each(&target_state) if target_state == :disable
      when DishCategory #same as store
        obj.dishes.each(&target_state) if target_state == :disable
      end
    end  
  end
  
  def self.propagate_price_change(obj)
    case obj
    when Dish
      obj.orderables.each(&:recalculate_price)
    when Milktea, MilkteaAddon
      obj.milktea_orderables.map(&:orderable).each(&:recalculate_price)
    end    
  end
  
end