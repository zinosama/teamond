require 'test_helper'

class PricePropagationTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:zino)
    
    @dish = recipes(:dish1)
    @milktea = recipes(:milktea1)
    #milktea_addon pending test #issue 139
    @milktea_addon = milktea_addons(:bubble) 
  end
  
  test 'dish price propagation' do
    new_price = @dish.price + 10
    
    log_in_as @admin
    patch recipe_path(@dish), recipe: { price: new_price, dish_category_id: @dish.dish_category.id, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg') }
    @dish.orderables.each do |orderable|
      assert_equal new_price, orderable.unit_price
    end
  end 
  
  test 'milktea price propagation' do
    orderables = []
    @milktea.milktea_orderables.map(&:orderable).each do |orderable|
      orderables << orderable
    end
    new_price = @milktea.price + 10
    
    log_in_as @admin
    patch recipe_path(@milktea), recipe: { price: new_price, image: fixture_file_upload('test/fixtures/images/salad.jpg','images/jpeg') }
    orderables.each do |orderable|
      assert_equal((orderable.unit_price + 10).to_i, orderable.reload.unit_price.to_i) 
    end
  end
  
  # test 'milktea addon price propagation' do
  #   #milktea_addon pending test #issue 139
  # end
end
