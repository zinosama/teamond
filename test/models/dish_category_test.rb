require 'test_helper'

class DishCategoryTest < ActiveSupport::TestCase

	def setup
		@rice = DishCategory.new(name: "Rice", description: "all kinds of rice", image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')) )
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
	
	test 'image should not too large' do
		@rice.image = File.open(File.join(Rails.root, '/test/fixtures/images/too-large.jpg'))
		assert_not @rice.valid?
	end

	test 'description should not be too long' do
		@rice.description = "a" * 256
		assert_not @rice.valid?
	end
end
