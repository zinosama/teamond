class Recipe < ActiveRecord::Base
	belongs_to :store
	
	validates :name, presence: true, length: { maximum: 50 }
	validates :description, presence: true, length: { maximum: 255 }
	validates :image, presence: true
	validates :price, presence: true, numericality: { greater_than: 0 }
	validates :type, presence: true
	validates :store, presence: true
	
	mount_uploader :image, PictureUploader
	validate :picture_size
	
	after_update :propagate_state_change

	def activate
		update_attribute(:active, true)
		propagate_state_change
	end

	def disable
		update_attribute(:active, false)
		propagate_state_change
	end

	private

		def propagate_state_change
			StatusPropagator.propagate_state_change(self)
		end

		def picture_size
			errors.add(:image, "should be less than 1MB") if image.size > 1.megabytes
		end

end
