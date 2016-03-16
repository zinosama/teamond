require 'test_helper'

class OderableTest < ActiveSupport::TestCase
	belongs_to :ownable, :polymorphic => true
end
