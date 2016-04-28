require 'test_helper'

class ShopperTest < ActiveSupport::TestCase

	def setup
		@persisted_user = users(:ed)
		user = User.new
		@shopper = Shopper.new(user: user)
	end

	test 'should be valid' do
		assert @shopper.valid?
	end

	test 'cannot assign to persisted user' do
		@shopper.user = @persisted_user
		assert_not @shopper.valid?
	end

	test 'should have a user' do
		@shopper.user = nil
		assert_not @shopper.valid?
	end
end
