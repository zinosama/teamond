require 'test_helper'

class AddonsOrderableTest < ActiveSupport::TestCase

	def setup
		addon = milktea_addons(:milktea_addon1)
		milktea_orderable = milktea_orderables(:milktea_orderable1)
		@record = AddonsOrderable.new(milktea_addon: addon, milktea_orderable: milktea_orderable)
	end

	test 'should be valid' do
		assert @record.valid?
	end

	test 'should have milktea addon' do
		@record.milktea_addon = nil
		assert_not @record.valid?
	end

	test 'should have milktea orderable' do
		@record.milktea_orderable = nil
		assert_not @record.valid?
	end
end
