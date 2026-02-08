# app/models/event.rb
class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Active Storage pour les photos
  has_many_attached :photos

  # Validations
  validates :title, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :starts_at, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :upcoming, -> { where('starts_at >= ?', Time.current).order(starts_at: :asc) }
  scope :verified, -> { where(is_verified: true) }

  # Callbacks
  before_save :geocode_address, if: :address_changed?

  def price_display
    is_free ? 'Gratuit' : "#{price}€"
  end

# app/models/event.rb
  def photo_url
    return nil unless photos.attached?

    if Rails.env.production?
      blob = photos.first
      Cloudinary::Utils.cloudinary_url(blob.key)
    else
      # En développement : chemin relatif
      Rails.application.routes.url_helpers.rails_blob_path(photos.first, only_path: true)
    end
  end

  private

  def geocode_address
    # Tu peux utiliser Geocoder gem ou une API de géocodage
    # Pour l'instant on laisse nil, tu pourras implémenter plus tard
  end
end
