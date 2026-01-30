# app/models/event.rb
class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Validations
  validates :title, presence: true
  validates :city, presence: true
  validates :starts_at, presence: true
  validates :event_type, inclusion: { in: %w[soiree cours festival] }
  validates :level, inclusion: { in: %w[debutant intermediaire avance tous] }, allow_nil: true

  # Geocoding
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj) { obj.address_changed? && obj.address.present? }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :upcoming, -> { where('starts_at >= ?', Time.current).order(starts_at: :asc) }
  scope :in_city, ->(city) { where('LOWER(city) = ?', city.downcase) if city.present? }
  scope :by_style, ->(style) { where('? = ANY(dance_styles)', style) if style.present? }
  scope :free_events, -> { where(is_free: true) }
  scope :with_lessons, -> { where(has_lessons: true) }

  # Méthodes
  def full_address
    [address, postal_code, city].compact.join(', ')
  end

  def tonight?
    starts_at.to_date == Date.current
  end

  def this_week?
    starts_at.to_date.between?(Date.current, Date.current + 7.days)
  end

  def price_display
    return "Gratuit" if is_free
    return "#{price}€" if price.present?
    "Prix non communiqué"
  end

  def styles_display
    return "Toutes danses" if dance_styles.blank?
    dance_styles.map(&:capitalize).join(', ')
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
