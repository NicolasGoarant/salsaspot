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

  private

  def geocode_address
    # Tu peux utiliser Geocoder gem ou une API de géocodage
    # Pour l'instant on laisse nil, tu pourras implémenter plus tard
  end

  def level_display
    case level
    when 'debutant' then '🟢 Débutant'
    when 'intermediaire' then '🟡 Intermédiaire'
    when 'avance' then '🔴 Avancé'
    else '⚪️ Tous niveaux'
    end
  end
end
