require 'test_helper'

class StoreCreateTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:zino)
	end

	test 'valid new page' do
		log_in_as @admin
		get new_store_url

		assert_template 'stores/new'
		assert_select 'title', full_title("New Store")
		assert_select 'form[action=?]', stores_path, count: 1
		assert_select 'form[method=?]', 'post', count: 1
		
		assert_select 'a[href=?]', stores_url, count: 1
	end

	test 'valid store' do
		log_in_as @admin
		
		assert_difference 'Store.count', 1 do
			post stores_url, store: { name: "new store", phone: "12312", owner: "harry", address: "500 joseph c"}
		end
		store = assigns(:store)
		assert_redirected_to store_url(store)
		assert_not flash[:success].empty?

		assert store.persisted?
		assert_equal "new store", store.name
		assert_equal "12312", store.phone
		assert_equal "harry", store.owner
		assert_equal "500 joseph c", store.address
		assert_not store.active?
		#temp test for lat and long placeholder
		assert_equal 0, store.lat.to_i
		assert_equal 0, store.long.to_i
	end
	

end
