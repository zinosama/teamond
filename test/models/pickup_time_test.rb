require 'test_helper'

class PickupTimeTest < ActiveSupport::TestCase

	def setup
		@time = PickupTime.new( pickup_hour: 2, pickup_minute: 20, cutoff_hour: 1, cutoff_minute: 30 )
	end

	test 'should be valid' do
		assert @time.valid?
	end 

	test 'should have a pickup hour' do
		@time.pickup_hour = ""
		assert_not @time.valid?
	end

	test 'pickup_hour should be (0..23)' do
		@time.pickup_hour = -1
		assert_not @time.valid?
		@time.pickup_hour = 24
		assert_not @time.valid?
	end

	test 'should have a pickup_minute' do
		@time.pickup_minute = ""
		assert_not @time.valid?
	end

	test 'pickup_minute should be (0..59)' do
		@time.pickup_minute = -1
		assert_not @time.valid?
		@time.pickup_minute = 60
		assert_not @time.valid?
	end

	test 'should have a cutoff_hour' do
		@time.cutoff_hour = ""
		assert_not @time.valid?
	end

	test 'cutoff_hour should be (0..23)' do
		@time.cutoff_hour = -1
		assert_not @time.valid?
		@time.cutoff_hour = 24
		assert_not @time.valid?
	end

	test 'shoud have a cutoff_minute' do
		@time.cutoff_minute = ""
		assert_not @time.valid?
	end

	test 'cutoff_minute should be (0..59)' do
		@time.cutoff_minute = -1
		assert_not @time.valid?
		@time.cutoff_minute = 60
		assert_not @time.valid?
	end

end
