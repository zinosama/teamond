class PickupLocationsController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin

	def new
		@location = PickupLocation.new
	end
end
