require 'test_helper'

class LocationsTimeTest < ActiveSupport::TestCase

	def setup
		pickup_time = pickup_times(:one)
		pickup_location = pickup_locations(:one)
		@record = LocationsTime.new( pickup_time: pickup_time, pickup_location: pickup_location, day_of_week: 2)
	end

	test 'should be valid' do
		assert @record.valid?
	end

	test 'should have a pickup time' do
		@record.pickup_time = nil
		assert_not @record.valid?
	end
	
	test 'should have a pickup location' do
		@record.pickup_location = nil
		assert_not @record.valid?
	end

	test 'should have a day of week' do
		@record.day_of_week = ""
		assert_not @record.valid?
	end

	test 'day of week should be (0..6)' do
		@record.day_of_week = -1
		assert_not @record.valid?
		@record.day_of_week = 7
		assert_not @record.valid?
	end

end
