module Roleable
	extend ActiveSupport::Concern
	included do
		has_one :user, as: :role

		validates :user, presence: true
		validate :new_user?
	end

	def new_user?
		errors.add(:user_id, "is persisted!") if user && user.persisted?
	end
end