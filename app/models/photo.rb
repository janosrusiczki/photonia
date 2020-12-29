class Photo < ApplicationRecord
  extend FriendlyId
  friendly_id :flickr_id, use: :slugged

  include ImageUploader::Attachment(:image)

  acts_as_taggable_on :tags

  default_scope { where(privacy: 'public') }

  belongs_to :user

  def next
    Photo.where('date_taken > ?', date_taken).order(:date_taken).first
  end

  def prev
    Photo.where('date_taken < ?', date_taken).order(date_taken: :desc).first
  end
end
