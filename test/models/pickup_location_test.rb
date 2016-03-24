require 'test_helper'

class PickupLocationTest < ActiveSupport::TestCase

	def setup
		@location = PickupLocation.new( name: "Wilson Commons", address: "500 Joseph c wilson blvd", description: "front door facing gym")
	end

	test 'should be valid' do
		assert @location.valid?
	end	

	test 'should have name' do
		@location.name = ""
		assert_not @location.valid?
	end

	test 'name should not be too long' do
		@location.name = "a" * 31
		assert_not @location.valid?
	end

	test 'should have address' do
		@location.address = ""
		assert_not @location.valid?
	end

	test 'address should not be too long' do
		@location.address = "a" * 256
		assert_not @location.valid?
	end

	test 'description should not be too long' do 
		@location.description = "a" * 256
		assert_not @location.valid?
	end
end
