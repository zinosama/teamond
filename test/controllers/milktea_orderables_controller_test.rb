require 'test_helper'

class MilkteaOrderablesControllerTest < ActionController::TestCase
	
	def setup
		@milktea = recipes(:milktea1)
	end

	test 'should get new' do
		get :new, milktea_id: @milktea
		assert_response :success
		assert_select "title", full_title("Customize Milktea")
	end

end
