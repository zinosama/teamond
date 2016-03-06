class DishCategory < ActiveRecord::Base
	has_many :dishes, dependent: :destroy
	mount_uploader :image, PictureUploader

	validates :name, presence: true, length: { maximum: 50 }
	validate :picture_size

	private

	def picture_size
		errors.add(:image, "should be less than 1MB") if image.size > 1.megabytes
	end
end
