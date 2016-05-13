require 'test_helper'

class StoreIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:zino)
  end
  
  test 'valid index page' do
    log_in_as @admin
    get stores_url
    assert_template 'stores/index'
    assert_select 'title', full_title("Store Management")
    
    Store.all.each do |store|
      assert_select 'a[href=?]', store_url(store), text: store.name.capitalize, count: 1
    end
    
  end
end
