require 'test_helper'

class ProviderTest < ActiveSupport::TestCase

	def setup
		store = stores(:one)
		user = users(:ed)
		@provider = Provider.new(store: store, user: user)
	end

	test 'should be valid' do
		assert @provider.valid?
	end

	test 'should have a store' do
		@provider.store = nil
		assert_not @provider.valid?
	end

	test 'should have a user' do
		@provider.user = nil
		assert_not @provider.valid?
	end
end 
