class StoresController < ApplicationController
	before_action :logged_in_user
	before_action :valid_store, only: [:show, :edit, :update]

	after_action :verify_authorized

	def new
		authorize Store
		@store = Store.new
	end

	def create
		authorize Store
		@store = Store.new store_params
		@store.save ? redirect_and_flash(store_url(@store), :success, "Store created") : render('new')
	end

	def show
		authorize @store
	end	
	
	def edit
		authorize @store
	end
	
	def update
		authorize @store
		if @store.update_attributes(store_params)
			redirect_and_flash(store_url(@store), :success, "Store updated")
		else
			render 'edit'
		end
	end
	
	private 

		def store_params
			params.require(:store).permit(policy(Store).permitted_attributes)
		end

		def valid_store
			@store = Store.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Invalid store")
		end	

end
