require 'test_helper'

class UserTest < ActiveSupport::TestCase
	
	def setup 
		@user = User.new(name: "Test User", email: "user@example.com", phone: "5853231234", password_digest: "fakepassword")
	end

	test "should be valid" do 
		@user.valid?
	end

	test "name should be present" do
		@user.name = "  "
		assert_not @user.valid?
	end
end
