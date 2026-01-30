class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      # Infos de base
      t.string :title, null: false
      t.text :description
      t.string :slug

      # Catégorisation
      t.string :event_type
      t.string :dance_styles, array: true, default: []
      t.string :level

      # Lieu
      t.string :venue_name
      t.string :address
      t.string :city
      t.string :postal_code
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      # Timing
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :recurrence
      t.integer :day_of_week

      # Infos pratiques
      t.decimal :price, precision: 8, scale: 2
      t.boolean :is_free, default: false
      t.boolean :has_lessons, default: false
      t.string :lessons_time

      # Contact & liens
      t.string :organizer_name
      t.string :organizer_email
      t.string :phone
      t.string :website
      t.string :facebook_url
      t.string :ticket_url

      # Meta
      t.boolean :is_active, default: true
      t.boolean :is_verified, default: false
      t.integer :views_count, default: 0

      t.timestamps
    end

    add_index :events, :slug, unique: true
    add_index :events, [:latitude, :longitude]
    add_index :events, :starts_at
    add_index :events, :city
    add_index :events, :dance_styles, using: 'gin'
    add_index :events, :is_active
  end
end
