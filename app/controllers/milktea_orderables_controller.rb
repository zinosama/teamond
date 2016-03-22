class MilkteaOrderablesController < ApplicationController
	before_action :logged_in_user
	
	def new
		@milktea = Milktea.find_by(id: params[:milktea_id])
		unless @milktea
			redirect_to menu_url
			flash[:error] = "Error loading selected milktea"
		end
		@milktea_orderable = MilkteaOrderable.new
	end

	def create
		@milktea = Milktea.find(1)
		@milktea_orderable = MilkteaOrderable.new
		render "new", id: 1
	end

end
