class Shopper < ActiveRecord::Base
	include Roleable

	has_many :orders, dependent: :destroy
	has_many :orderables, as: :ownable, dependent: :destroy

	def name
		user.name
	end

	def phone
		user.phone
	end

	def wechat
		user.wechat
	end

	def email
		user.email
	end

	def invalid_orderables?
		orderables.where.not(status: 0).any?
	end

	def item_count
		self.orderables.count
	end

	def cart_balance_before_tax
		cart_balance.round(2)
	end

	def cart_balance_tax
		(cart_balance_before_tax * 0.08).round(2)
	end	

	def cart_balance_after_tax
		cart_balance_before_tax + cart_balance_tax
	end

	def cart_balance_after_tax_in_penny
		cart_balance_after_tax * 100.to_i
	end

	private 

		def cart_balance
			@sum ||= 0
			self.orderables.each{ |orderable| @sum += orderable.unit_price * orderable.quantity } if @sum == 0
			@sum
		end
end
