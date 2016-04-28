require 'test_helper'

class ProviderTest < ActiveSupport::TestCase

	def setup
		store = stores(:one)
		@persisted_user = users(:ed)
		user = User.new
		@provider = Provider.new(store: store, user: user)
	end

	test 'should be valid' do
		assert @provider.valid?
	end

	test 'cannot assign to persisted user' do
		@provider.user = @persisted_user
		assert_not @provider.valid?
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
