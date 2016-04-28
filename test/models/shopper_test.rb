require 'test_helper'

class ShopperTest < ActiveSupport::TestCase

	def setup
		@shopper = Shopper.new
	end

	test 'should not be valid' do
		assert_not @shopper.valid?
	end

	test 'should associate with a user' do
		user = users(:ed)
		@shopper.user = user
		assert @shopper.valid?
	end
end
