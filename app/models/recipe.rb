class Recipe < ActiveRecord::Base
	include Propagatable
	scope :active, -> { where(active: true) }

	belongs_to :store
	
	validates :name, presence: true, length: { maximum: 50 }
	validates :description, presence: true, length: { maximum: 255 }
	validates :image, presence: true
	validates :price, presence: true, numericality: { greater_than: 0 }
	validates :type, presence: true, inclusion: { in: ["Dish", "Milktea"], message: "%{value} is not a valid type" }
	validates :store, presence: true
	
	mount_uploader :image, PictureUploader
	validate :picture_size
	validate :immutable_type
	
	after_update :propagate_state_change
	after_update :propagate_price_change
	
	def disable
		update_attribute(:active, false)
	end
	
	def activate
		update_attribute(:active, true)
	end
	
	def unit_price
		price
	end

	private

		def immutable_type
			 errors.add(:type, "cannot be changed" ) if type_changed? && persisted?			
		end

		def picture_size
			errors.add(:image, "should be less than 1MB") if image.size > 1.megabytes
		end

end
