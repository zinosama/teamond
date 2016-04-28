require 'test_helper'

class AdminTest < ActiveSupport::TestCase

	def setup
		user = users(:ed)
		@admin = Admin.new(user: user)
	end

	test 'should be valid' do
		assert @admin.valid?
	end

	test 'should have a user' do
		@admin.user = nil
		assert_not @admin.valid?
	end	
end
