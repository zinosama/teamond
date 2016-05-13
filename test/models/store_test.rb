require 'test_helper'

class StoreTest < ActiveSupport::TestCase

	def setup
		@store = Store.new(name: "store", phone: "2311312", address: "address", owner: "Harry Porter", lat: 31.31, long: 31.32)
	end

	test 'should be valid' do
		assert @store.valid?
	end	

	test 'should have a name' do
		@store.name = ""
		assert_not @store.valid?
	end
	test 'name should not be too long' do
		@store.name = "a" * 51
		assert_not @store.valid?
	end

	test 'should have a phone number' do
		@store.phone = ""
		assert_not @store.valid?
	end
	test 'phone number should not be too long' do
		@store.phone = "a" * 21
		assert_not @store.valid?
	end

	test 'should have an owner' do
		@store.owner = ""
		assert_not @store.valid?
	end
	test 'owner should not be too long' do
		@store.owner = "a" * 256
		assert_not @store.valid?
	end

	test 'should have an address' do
		@store.address = ""
		assert_not @store.valid?
	end
	test 'address should not be too long' do
		@store.address = "a" * 256
		assert_not @store.valid?
	end	

	#optional attributes

	test 'email should not be too long' do
		@store.email = "a" * 256
		assert_not @store.valid?
	end

	test 'website should not be too long' do
		@store.website = "a" * 256
		assert_not @store.valid?
	end

end
