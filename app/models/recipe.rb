class Recipe < ActiveRecord::Base
	validates :name, presence: true, length: { maximum: 50 }
	validates :description, presence: true, length: { maximum: 255 }
	validates :image, presence: true
	validates :price, presence: true, numericality: { greater_than: 0 }
	validates :type, presence: true

	mount_uploader :image, PictureUploader
	validate :picture_size

	def activate
		self.update_attribute(:active, true)
		self.update_associated_orderables(:active)
	end

	def disable
		self.update_attribute(:active, false)
		self.update_associated_orderables(:disabled)
	end

	private

	def picture_size
		errors.add(:image, "should be less than 1MB") if image.size > 1.megabytes
	end

end
