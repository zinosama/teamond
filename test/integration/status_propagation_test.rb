require 'test_helper'

class StatusPropagationTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:zino)
    @shopper1 = users(:ed)
    @shopper2 = users(:shopper2) 
    @shopper_empty = users(:shopper_empty)
    
    @store = stores(:one)
    @milktea = recipes(:milktea1)
    @orderable = orderables(:two)
  end 
  
  #######RECIPE PROPAGATIONS########
  test 'dish propagation' do
    dish = recipes(:dish1)
    assert dish.active? #initial state: active
    
    log_in_as @admin #dish: active -> updated
    patch recipe_path(dish), recipe: { dish_category_id: dish.dish_category.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
    orderable_propagation(dish, :patch)

    log_in_as @admin #dish: active -> inactive
    patch recipe_path(dish), recipe: { active: "0" }
    assert_not dish.reload.active?
    orderable_propagation(dish, :disable) 
  end
  
  test 'milktea propagation' do
    assert @milktea.active? #initial state: active
    
    log_in_as @admin #milktea: active -> updated
    patch_milktea @milktea, :update
    orderable_propagation(@milktea, :patch)
    
    log_in_as @admin #milktea: active -> inactive
    patch_milktea @milktea, :disable
    assert_not @milktea.reload.active?
    orderable_propagation(@milktea, :disable)
  end
  
  ######Milktea Addon Propagation#######
  
  test 'addon propagation' do
    addon = milktea_addons(:bubble)
    assert addon.active? #initial state: active
    assert_equal 1, addon.milktea_orderables.size
    
    log_in_as @admin
    patch_addon addon, :update
    orderable_propagation(addon, :patch)
    
    log_in_as @admin
    patch_addon addon, :disable
    assert_not addon.reload.active?
    orderable_propagation(addon, :disable)    
  end
  
  #####Addon & Milktea Edge Cases#########
  test 'milktea edge case 1' do
    #issue: updated addon 
    #check: remove the addon returns milktea orderable to active (no need to confirm again)           
    milktea_edge_setup :updated_addon
    assert @orderable.active? #check initial active
    
    patch_addon @addon, :update
    assert @orderable.reload.updated?
    
    goto_cart_of @shopper_empty, :see, :warning
    
    patch milktea_orderable_path(@orderable.buyable), milktea_orderable: { milktea_addon_ids: [""] }
    goto_cart_of @shopper_empty, :not_see, :warning
  end
  
  test 'milktea edge case 2' do
    #issue: inactive addon
    #check: remove the addon returns milktea orderable to active (...)
    milktea_edge_setup :inactive_addon
    assert @orderable.active? #check initial active
    
    patch_addon @addon, :disable
    assert @orderable.reload.inactive?
    
    goto_cart_of @shopper_empty, :see, :error
    
    patch milktea_orderable_path(@orderable.buyable), milktea_orderable: { milktea_addon_ids: [""] }
    goto_cart_of @shopper_empty, :not_see, :error
  end
  
  test 'milktea edge case 3' do
    #issue: inactivate milktea, updated addon
    #check: orderable should be inactive
    milktea_edge_setup :inactivate_milktea_updated_addon
    assert @orderable.reload.inactive?
    
    #check: update milktea, orderable remain inactive
    log_in_as @admin
    patch_milktea @milktea, :update
    assert_equal 'edited', @milktea.reload.description
    assert @orderable.reload.inactive?
  end
  
  test 'milktea edge case 4' do
    #issue: inactivate addon, updated milktea 
    #check: orderable should be inactive
    milktea_edge_setup :inactive_addon_updated_milktea
    assert @orderable.reload.inactive?
    
    #check: update addon, orderable should still be inactive
    patch_addon @addon, :update
    assert @orderable.reload.inactive?
    
    #check: remove addon, orderable should be active (...)
    log_in_as @shopper_empty 
    patch milktea_orderable_path(@orderable.buyable), milktea_orderable: { milktea_addon_ids: [""] }
    assert @orderable.reload.active?
  end
  
  ########Store Propagation########
  
  test 'store propagation' do
    assert @store.active?
  
    log_in_as @admin
    patch store_path(@store), store: { active: "0" }
    follow_redirect!
    assert_not @store.reload.active?
    @store.recipes.each{ |recipe| orderable_propagation(recipe, :disable) }
  end
  
  
  private
  
    def milktea_edge_setup(target_state)
      @addon = milktea_addons(:bubble)
      log_in_as @shopper_empty
      shopper = @shopper_empty.role
      post shopper_milktea_orderables_path(shopper), milktea_orderable: { sweet_scale: 1, temp_scale: 1, size: 1, milktea_addon_ids: [@addon.id] }, milktea_id: @milktea.id
      assert_equal 1, @shopper_empty.role.orderables.size #check setup
      @orderable = @shopper_empty.role.orderables.first
      
      if target_state == :inactivate_milktea_updated_addon
        patch_milktea @milktea, :disable
        assert_not @milktea.reload.active?
        assert @orderable.reload.inactive?
        patch_addon @addon, :update
      elsif target_state == :inactive_addon_updated_milktea
        patch_addon @addon, :disable
        assert_not @addon.reload.active?
        assert @orderable.reload.inactive?
        patch_milktea @milktea, :update
      end
    end
    
    def goto_cart_of(user, precense, flash_type)
      log_in_as user
      get shopper_cart_url(user.role)
      send( (precense == :see ? :assert_not : :assert), flash[flash_type].nil?)
    end
    
    def patch_milktea(milktea, target_state)
      log_in_as @admin
      param = case target_state
      when :disable
        { active: "0" }
      when :activate
        { active: "1" }
      when :update
        { image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg'), description: "edited" }
      end
      patch recipe_path(milktea), recipe: param
    end
    
    def patch_addon(addon, target_state)
      log_in_as @admin
      param = case target_state
      when :disable
        { active: "0" }
      when :update
        { price: 0.9 }
      when :activate
        { active: "1"}
      end
      patch milktea_addon_path(addon), milktea_addon: param
    end
    
    
    def orderable_propagation(source, action)
      #test state setup
      orderable_status = (action == :patch ? :updated? : :inactive?)
      flash_key = (action == :patch ? :warning : :error)
      orderables = case source
      when Dish
        source.orderables
      when Milktea, MilkteaAddon
        source.milktea_orderables.map(&:orderable)
      end
      affected_users = []
      
      orderables.each do |orderable|
        assert orderable.reload.send(orderable_status)
        shopper = orderable.ownable
        unless affected_users.include? shopper.user
          affected_users << shopper.user
          
          goto_cart_of shopper.user, :see, flash_key
          assert_select "div.ui.#{flash_key}.message", count: (shopper.orderables.updated.size + shopper.orderables.inactive.size + 1)
          
          #checkout pages are deactivated
          unable_to_get_checkout_page(shopper)
          unable_to_post_order(shopper)
          
          if action == :patch #shopper confirm change
            patch orderable_url(orderable), status: "0"
            assert_redirected_to shopper_cart_url(shopper)
            assert orderable.reload.active?
          end        
        end
      end
    end
  
    def unable_to_get_checkout_page(shopper)
      flash[:error] = nil
      get shopper_checkout_url(shopper)
      assert_redirected_to shopper_cart_url(shopper)
      assert_equal "Please remove unavailable or verify changed items before checkout", flash[:error]
    end
    
    def unable_to_post_order(shopper)
      flash[:error] = nil 
      assert_no_difference 'Order.count' do
        post locations_time_orders_url(locations_times(:one)), order: { payment_method: "1", recipient_name: "yo", recipient_phone: "47283" }
      end
      assert_redirected_to shopper_cart_url(shopper)
      assert_equal "Please remove unavailable or verify changed items before checkout", flash[:error]      
    end
end
