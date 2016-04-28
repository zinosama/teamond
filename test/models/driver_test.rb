require 'test_helper'

class DriverTest < ActiveSupport::TestCase

	def setup
		user = users(:ed)
		@driver = Driver.new(user: user)
	end

	test 'should be valid' do
		assert @driver.valid?
	end

	test 'should have a user' do
		@driver.user = nil
		assert_not @driver.valid?
	end
end
