class AddonsOrderable < ActiveRecord::Base
	belongs_to :milktea_orderable
	belongs_to :milktea_addon

	validates :milktea_orderable, presence: true
	validates :milktea_addon, presence: true
end
