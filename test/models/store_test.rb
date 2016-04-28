require 'test_helper'

class StoreTest < ActiveSupport::TestCase

	def setup
		@store = Store.new(name: "store", address: "address")
	end

	test 'should be valid' do
		assert @store.valid?
	end	

	test 'should have a name' do
		@store.name = ""
		assert_not @store.valid?
	end

	test 'should have an address' do
		@store.address = ""
		assert_not @store.valid?
	end

	test 'name should not be too long' do
		@store.name = "a" * 51
		assert_not @store.valid?
	end

	test 'address should not be too long' do
		@store.address = "a" * 256
		assert_not @store.valid?
	end
end
