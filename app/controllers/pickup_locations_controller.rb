class PickupLocationsController < ApplicationController
	before_action :logged_in_user
	before_action :logged_in_admin

	def index
		@location = PickupLocation.new
	end

	def create
		
	end
end
