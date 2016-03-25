require 'test_helper'

class PickupTimeTest < ActiveSupport::TestCase

	def setup
		@time = PickupTime.new( time: DateTime.now )
	end

	test 'should be valid' do
		assert @time.valid?
	end 

	test 'should have a time' do
		@time.time = nil
		assert_not @time.valid?
	end
end
