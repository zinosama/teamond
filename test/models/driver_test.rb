require 'test_helper'

class DriverTest < ActiveSupport::TestCase

	def setup
		@persisted_user = users(:ed)
		user = User.new
		@driver = Driver.new(user: user)
	end
	
	test 'should be valid' do
		assert @driver.valid?
	end

	test 'cannot assign to persisted user' do
		@driver.user = @persisted_user
		assert_not @driver.valid?
	end

	test 'should have a user' do
		@driver.user = nil
		assert_not @driver.valid?
	end

end
