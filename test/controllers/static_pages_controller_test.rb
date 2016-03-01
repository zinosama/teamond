require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase

	def setup
		@base_title = "Teamond"
	end 

	test 'should get home' do 
		get :home
		assert_response :success
		assert_select "title", "#{@base_title}"
	end

	test 'should get contact' do
		get :contact
		assert_response :success
		assert_select "title", "Contact | #{@base_title}"
	end

	test 'should get about' do
		get :about
		assert_response :success
		assert_select "title", "About | #{@base_title}"
	end

	test 'should get questions' do
		get :questions
		assert_response :success
		assert_select "title","Questions | #{@base_title}" 
	end

	test 'should get jobs' do
		get :career
		assert_response :success
		assert_select "title", "Career | #{@base_title}"
	end
end
