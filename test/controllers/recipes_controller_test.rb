require 'test_helper'

class RecipesControllerTest < ActionController::TestCase
	
	def setup
		@admin = users(:zino)
		@user = users(:ed)
		@new_category = DishCategory.create(name: "new category", description: "description")
	end

	test 'should redirect manage when not logged in' do
		get :manage
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect manage when logged in as non-admin' do
		log_in_as @user
		get :manage
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should get manage when logged in as admin' do
		log_in_as @admin
		get :manage
		assert_response :success
		assert_select "title", "Menu Management | Teamond"
	end

	test 'should redirect create when not logged in' do
		assert_no_difference 'Recipe.count' do
			post :create, recipe: { name: "dukbokki", price: 1.23, type: "dish", dish_category_id: @new_category.id, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')), description: "description"}
		end

		assert_redirected_to login_url
		assert_not flash.empty?		
	end

	test 'should redirect create when logged in as non-admin' do
		log_in_as @user
		assert_no_difference 'Recipe.count' do
			post :create, recipe: { name: "dukbokki", price: 1.23, type: "dish", dish_category_id: @new_category.id, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')), description: "description"}
		end

		assert_redirected_to root_url
		assert_not	flash.empty?
	end

	test 'should redirect edit when not logged in' do
		get :edit
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect edit when logged in as non-admin' do
		get :edit
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect update when not logged in' do
		recipe = Recipe.create(name: "dukbokki", price: 1.23, type: "dish", dish_category_id: @new_category.id, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')), description: "description")
		patch :update, id: recipe, recipe: { name: "dddubokki", price: 1.22, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad2.jpg')), description: "Hi"}
		assert_redirected_to login_url
		assert_not flash.empty? 
	end

	test 'should redirect update when logged in as non-admin' do
		recipe = Recipe.create(name: "dukbokki", price: 1.23, type: "dish", dish_category_id: @new_category.id, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')), description: "description")
		patch :update, id: recipe, recipe: { name: "dddubokki", price: 1.22, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad2.jpg')), description: "Hi"}
		assert_redirected_to root_url
		assert_not flash.empty?
	end

	test 'should redirect delete when not logged in' do
		recipe = Recipe.create(name: "dukbokki", price: 1.23, type: "dish", dish_category_id: @new_category.id, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')), description: "description")
		
		assert_no_difference 'Recipe.count' do
			delete :destroy, id: recipe
		end
		
		assert_redirected_to login_url
		assert_not flash.empty?
	end

	test 'should redirect delete when logged in as non-admin' do
		recipe = Recipe.create(name: "dukbokki", price: 1.23, type: "dish", dish_category_id: @new_category.id, image: File.open(File.join(Rails.root, '/test/fixtures/images/salad.jpg')), description: "description")
		
		assert_no_difference 'Recipe.count' do
			delete :destroy, id: recipe
		end
		
		assert_redirected_to root_url
		assert_not flash.empty?
	end
end
