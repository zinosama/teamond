require 'test_helper'

class RecipeTest < ActiveSupport::TestCase

	def setup
		fried_rice = DishCategory.new(name: "Rice")
		@store = stores(:one)
		@dish = fried_rice.dishes.build(name: "Fried Rice", description: "fried rice with little nutrition.", price: 12.11, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')), store: @store )
	end

	#basic attributes testing

	test 'dish should be subclass of recipe' do
		assert @dish.valid?
	end

	test 'milktea should be subclass of recipe' do
		milktea = Recipe.new(name: "bubble tea", description: "sugar water that makes you fat. Sorry.", price: 3, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')), type: "Milktea", store: @store)
		assert milktea.valid?
	end

	test 'name should be present' do
		@dish.name = " "
		assert_not @dish.valid?
	end

	test 'name should not be too long' do
		@dish.name = "a" * 51
		assert_not @dish.valid?
	end

	test 'description should be present' do
		@dish.description = "  "
		assert_not @dish.valid?
	end

	test 'description should not be too long' do
		@dish.description = "a" * 256
		assert_not @dish.valid?
	end	

	test 'image should be present' do
		@dish.image = " "
		assert_not @dish.valid?
	end

	test 'image should not be too large' do
		@dish.image = File.open(File.join(Rails.root, '/test/fixtures/images/too-large.jpg'))
		assert_not @dish.valid?
	end

	test 'price should be present' do
		@dish.price = nil 
		assert_not @dish.valid?
	end 

	test 'price should be greater than 0' do
		@dish.price = -1.2
		assert_not @dish.valid?
		@dish.price = 0
		assert_not @dish.valid?
	end

	test 'price should be allowed as string' do
		@dish.price = "1.2"
		assert @dish.valid?
	end

	test 'type must be present' do
		@dish.type = ""
		assert_not @dish.valid?
	end 
	#sub-class attributes testing

	test 'dish must have category' do
		@dish.dish_category = nil
		assert_not @dish.valid?
	end

	test 'milktea cannot have category' do
		milktea = Recipe.new(name: "bubble tea", description: "sugar water that makes you fat. Sorry.", price: 3, image: "path_to_image", type: "Milktea")
		milktea.dish_category_id = 1
		assert_not milktea.valid?
	end

	test 'store should be present' do
		@dish.store = nil
		assert_not @dish.valid?
	end
	
end
