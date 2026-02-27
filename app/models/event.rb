# app/models/event.rb
class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Active Storage pour les photos
  has_many_attached :photos

  # Geocoder
  geocoded_by :full_address
  after_validation :geocode, if: :should_geocode?

  # Validations
  validates :title, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :starts_at, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :upcoming, -> { where('starts_at >= ?', Time.current).order(starts_at: :asc) }
  scope :verified, -> { where(is_verified: true) }

  def price_display
    if is_free || price.nil? || price == 0
      'Gratuit'
    elsif price % 1 == 0
      "#{price.to_i}€"
    else
      "#{format('%.2f', price).gsub('.', ',')}€"
    end
  end

  def photo_url
    return nil unless photos.attached?

    if Rails.env.production?
      blob = photos.first
      Cloudinary::Utils.cloudinary_url(blob.key)
    else
      Rails.application.routes.url_helpers.rails_blob_path(photos.first, only_path: true)
    end
  end

  # URL de la photo pour les OG tags (absolue)
  def og_photo_url
    if photos.attached? && Rails.env.production?
      Cloudinary::Utils.cloudinary_url(photos.first.key)
    else
      nil
    end
  end

  private

  def full_address
    [address, city, postal_code, "France"].compact.join(", ")
  end

  def should_geocode?
    (latitude.blank? || longitude.blank?) || address_changed? || city_changed?
  end
end
