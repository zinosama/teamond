require 'test_helper'

class StoreShowTest < ActionDispatch::IntegrationTest
  
  def setup
    @store = stores(:one)
    @admin = users(:zino)
  end
  
  test 'valid show page' do
    log_in_as @admin
    get store_url(@store)
    assert_template 'stores/show'
    assert_select 'title', full_title(@store.name)
    
    assert_select 'a[href=?]', edit_store_url(@store), count: 1
    assert_select 'a[href=?]', @store.website, count: 1
    
    # pending tests:
    # assert_select 'a[href=?]', new_provider_url, count: 1
    # assert_select 'a[href=?]', stores_url, count: 1
  end 
  
end
