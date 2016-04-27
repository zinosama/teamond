class User < ActiveRecord::Base
	attr_accessor :remember_token, :activation_token, :reset_token

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	has_secure_password

	before_save :downcase_email
	before_create :create_activation_digest

	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true #allows nil so that user can update without password. nil is checked in has_secure_password.
	validates :wechat, allow_nil: true, length: { maximum: 50 }
	validates :phone, allow_nil: true, length: { maximum: 25 }
	validates :role, presence: true
	
	has_many :orders, dependent: :destroy
	has_many :orderables, as: :ownable
	belongs_to :role, :polymorphic => true

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

	def self.digest(input_string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(input_string, cost: cost)
	end

	def self.new_token
		SecureRandom.urlsafe_base64
	end

	def remember 
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def authenticated?(attribute, token)
		digest = self.send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

  def activate
  	update_columns(activated: true, activated_at: Time.zone.now)
  end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def create_password_reset_digest
		self.reset_token = User.new_token
		update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end
	
	private

	def cart_balance
		@sum ||= 0
		self.orderables.each{ |orderable| @sum += orderable.unit_price * orderable.quantity } if @sum == 0
		@sum
	end

	def downcase_email
		self.email.downcase!
	end

	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(activation_token)
	end

end
