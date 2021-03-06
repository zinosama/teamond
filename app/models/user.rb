class User < ActiveRecord::Base
	attr_accessor :remember_token, :activation_token, :reset_token

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	ROLE_TYPES = %w(Admin Shopper Driver Provider)
	has_secure_password

	before_save :downcase_email, :default_role
	before_create :create_activation_digest

	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true #allows nil so that user can update without password. nil is checked in has_secure_password.
	validates :wechat, allow_nil: true, length: { maximum: 50 }
	validates :phone, allow_nil: true, length: { maximum: 25 }
	validate :immutable_role?

	belongs_to :role, :polymorphic => true, dependent: :destroy
	accepts_nested_attributes_for :role

	def build_role(params) #this is called by accepts_nested_attributes_for. It helps polymorphism to figure out correct association
		raise Exceptions::UnknownRoleError unless ROLE_TYPES.include? role_type
		self.role = role_type.constantize.new( role_type == "Provider" ? params : nil )
		self.role.user = self
	end

	def admin?
		role_type == "Admin"
	end

	def shopper?
		role_type == "Shopper"
	end

	def driver?
		role_type == "Driver"
	end

	def provider?
		role_type == "Provider"
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

		def immutable_role?
			if persisted? && (role_id_changed? || role_type_changed?)
				errors.add(:role_id, "Change of user role not allowed!")
				false
			end
		end

		def default_role
			self.role = Shopper.create!(user: self) if new_record? && role.nil? 
		end

		def downcase_email
			self.email.downcase!
		end

		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end

end
