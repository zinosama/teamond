require 'test_helper'

class StoreEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:zino)
    @store = stores(:one)
  end
  
  test 'valid edit page' do
    log_in_as @admin
    get edit_store_url(@store)
    assert_template 'stores/edit'
    assert_select 'title', full_title('Edit Store')
    
    assert_select 'form[action=?]', stores_url(@store), count: 1
    assert_select 'form[method=?]', 'post', count: 1
    assert_select 'input[value=?]', 'patch', count: 1
  end
  
  test 'valid update' do
    log_in_as @admin
    patch stores_url(@store), store: { name: "new name", owner: "new owner", phone: "new phone", address: "new address", email: "new email", website: "new website", active: false }
    
    assert_redirected_to store_url(@store)
    assert_not flash[:success].empty?
    follow_redirect!
    @store.reload
    
    assert_equal "new name", @store.name
    assert_equal "new owner", @store.owner
    assert_equal "new phone", @store.phone
    assert_equal "new address", @store.address
    assert_equal "new email", @store.email
    assert_equal "new website", @store.website
    assert_not @store.active?
  end
  
  test 'invalid update' do
    log_in_as @admin
    patch stores_url(@store), store: { name: "", owner: "", phone: "", address: "", email: "a" * 256, website: "a" * 256 }
    
    assert_template 'stores/edit'
    assert_select 'div.ui.error.message', count: 1
    assert_select 'li', count: 6    
  end
end
