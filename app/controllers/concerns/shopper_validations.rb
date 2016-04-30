module ShopperValidations

	private

		def valid_user
			@shopper = Shopper.find(params[:shopper_id])
			redirect_and_flash(menu_url, :error, "Unauthorized request") unless current_user.role == @shopper
		rescue ActiveRecord::RecordNotFound
			redirect_and_flash(menu_url, :error, "Invalid request")
		end
end