require 'test_helper'

class AdminTest < ActiveSupport::TestCase

	def setup
		@persisted_user = users(:ed)
		user = User.new
		@admin = Admin.new(user: user)
	end

	test 'should be valid' do
		assert @admin.valid?
	end

	test 'cannot assign to persisted user' do
		@admin.user = @persisted_user
		assert_not @admin.valid?
	end

	test 'should have a user' do
		@admin.user = nil
		assert_not @admin.valid?
	end	
end
