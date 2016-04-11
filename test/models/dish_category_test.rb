require 'test_helper'

class DishCategoryTest < ActiveSupport::TestCase

	def setup
		@rice = DishCategory.new(name: "Rice")
	end

	test 'should be valid' do
		assert @rice.valid?
	end

	test 'name should be present' do
		@rice.name = " "
		assert_not @rice.valid?
	end

	test 'name should not be too long' do
		@rice.name = "a" * 51
		assert_not @rice.valid?
	end

end
