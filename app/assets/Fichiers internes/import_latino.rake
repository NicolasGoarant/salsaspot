# lib/tasks/import_latino.rake
#
# Usage:
#   rails import:latino
#   rails import:latino CALENDAR=57   (pour Metz)
#   rails import:latino CALENDAR=lux  (pour Luxembourg)
#
# Prérequis:
#   gem 'icalendar' dans le Gemfile + bundle install
#   (ou: gem install icalendar)

require 'net/http'
require 'uri'
require 'icalendar'

namespace :import do
  desc "Importer les événements depuis Rendez-Vous Latino (Google Calendar public)"
  task latino: :environment do

    # Calendriers disponibles
    calendars = {
      "54" => {
        id: "aaa6301bf9fa2c18e253c4f4ec78c3a5617c3698384305586980534c3f27fece@group.calendar.google.com",
        default_city: "Nancy"
      },
      # Ajoute les autres quand tu auras leurs IDs (même méthode : inspecter la page /57, /lux, /de)
      # "57" => { id: "XXXXXX@group.calendar.google.com", default_city: "Metz" },
      # "lux" => { id: "XXXXXX@group.calendar.google.com", default_city: "Luxembourg" },
    }

    calendar_key = ENV.fetch("CALENDAR", "54")
    cal_config = calendars[calendar_key]

    unless cal_config
      puts "❌ Calendrier '#{calendar_key}' non trouvé. Disponibles : #{calendars.keys.join(', ')}"
      exit 1
    end

    puts "📅 Import depuis Rendez-Vous Latino — #{calendar_key} (#{cal_config[:default_city]})"
    puts "=" * 60

    # 1. Télécharger le flux iCal public
    ical_url = "https://calendar.google.com/calendar/ical/#{cal_config[:id]}/public/basic.ics"
    puts "🔗 Téléchargement du calendrier..."

    uri = URI.parse(ical_url)
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      puts "❌ Erreur HTTP #{response.code} — le calendrier est peut-être privé"
      exit 1
    end

    # 2. Parser les événements iCal
    calendars_parsed = Icalendar::Calendar.parse(response.body)
    events = calendars_parsed.flat_map(&:events)
    puts "📋 #{events.size} événements trouvés au total"

    # Filtrer : uniquement les futurs
    future_events = events.select { |e| e.dtstart && e.dtstart.to_time >= Time.current.beginning_of_day }
    puts "📋 #{future_events.size} événements à venir\n\n"

    imported = 0
    skipped = 0

    future_events.each do |ical_event|
      title = ical_event.summary.to_s.strip
      description = ical_event.description.to_s.strip
      location = ical_event.location.to_s.strip
      starts_at = ical_event.dtstart.to_time
      ends_at = ical_event.dtend&.to_time

      # Dédoublonner : même titre + même date = skip
      if Event.exists?(title: title, starts_at: starts_at.beginning_of_day..starts_at.end_of_day)
        puts "⏭️  SKIP (déjà existant) : #{title}"
        skipped += 1
        next
      end

      # 3. Extraire les infos structurées depuis le titre + description
      parsed = parse_event(title, description, location, cal_config[:default_city])

      # 4. Créer l'événement
      event = Event.new(
        title: title,
        description: clean_description(description),
        venue_name: parsed[:venue_name],
        address: parsed[:address],
        city: parsed[:city],
        postal_code: parsed[:postal_code],
        starts_at: starts_at,
        ends_at: ends_at,
        dance_styles: parsed[:dance_styles],
        is_free: parsed[:is_free],
        price: parsed[:price],
        has_lessons: parsed[:has_lessons],
        lessons_time: parsed[:lessons_time],
        level: "tous",
        event_type: parsed[:event_type],
        is_active: false,  # ⚠️ En attente de validation manuelle
        organizer_name: "Rendez-Vous Latino (import)",
        source: "rendezvouslatino"
      )

      if event.save
        puts "✅ IMPORTÉ : #{title} — #{starts_at.strftime('%d/%m/%Y %Hh')}"
        imported += 1
      else
        puts "❌ ERREUR : #{title} — #{event.errors.full_messages.join(', ')}"
      end
    end

    puts "\n" + "=" * 60
    puts "🎉 Import terminé : #{imported} importés, #{skipped} ignorés (doublons)"
    puts "⚠️  Les events sont en is_active: false — valide-les depuis l'admin !"
  end
end

# --- Helpers de parsing ---

def parse_event(title, description, location, default_city)
  text = "#{title} #{description}".downcase

  # Styles de danse
  dance_styles = []
  dance_styles << "salsa" if text.match?(/salsa|sbk|social salsa|100% salsa/)
  dance_styles << "bachata" if text.match?(/bachata|bk |sensuelle/)
  dance_styles << "kizomba" if text.match?(/kizomba|kiz |kiznyo/)
  dance_styles << "salsa" if text.match?(/sbk/) && !dance_styles.include?("salsa")
  dance_styles << "bachata" if text.match?(/sbk/) && !dance_styles.include?("bachata")
  dance_styles << "kizomba" if text.match?(/sbk/) && !dance_styles.include?("kizomba")
  dance_styles = ["salsa"] if dance_styles.empty? # Fallback

  # Prix
  price_match = text.match(/(\d+)\s*€/)
  price = price_match ? price_match[1].to_f : nil
  is_free = text.match?(/gratuit|free|entrée offerte|entrée libre/)

  # Cours
  has_lessons = text.match?(/cours|initiation|stage|workshop|niveau/)
  lessons_time = nil
  if has_lessons
    time_match = text.match(/cours.*?(\d{1,2}h\d{0,2})/)
    time_match ||= text.match(/(\d{1,2}h\d{0,2}).*?cours/)
    time_match ||= text.match(/initiation.*?(\d{1,2}h)/)
    lessons_time = time_match ? time_match[1] : nil
  end

  # Type d'événement
  event_type = if text.match?(/festival|marathon/)
    "festival"
  elsif text.match?(/stage|workshop|bootcamp/)
    "stage"
  else
    "soiree"
  end

  # Lieu — parser la location Google Calendar
  venue_name, address, city, postal_code = parse_location(location, default_city)

  {
    dance_styles: dance_styles,
    price: price,
    is_free: is_free,
    has_lessons: has_lessons,
    lessons_time: lessons_time,
    event_type: event_type,
    venue_name: venue_name,
    address: address,
    city: city,
    postal_code: postal_code
  }
end

def parse_location(location, default_city)
  return [nil, nil, default_city, nil] if location.blank?

  parts = location.split(",").map(&:strip)

  venue_name = parts[0]
  address = nil
  city = default_city
  postal_code = nil

  parts.each do |part|
    # Chercher un code postal français (5 chiffres)
    if part.match?(/\b\d{5}\b/)
      match = part.match(/(\d{5})\s*(.*)/)
      if match
        postal_code = match[1]
        city = match[2].strip if match[2].present?
      end
    # Chercher une adresse (numéro + rue)
    elsif part.match?(/^\d+\s+(rue|boulevard|avenue|place|chemin|allée|impasse)/i)
      address = part
    end
  end

  [venue_name, address, city, postal_code]
end

def clean_description(desc)
  return nil if desc.blank?

  # Nettoyer les caractères HTML et les lignes vides multiples
  cleaned = desc
    .gsub(/<[^>]+>/, '')           # Strip HTML
    .gsub(/\r\n/, "\n")           # Normaliser les retours à la ligne
    .gsub(/\n{3,}/, "\n\n")       # Max 2 retours à la ligne
    .strip

  # Tronquer si trop long
  cleaned.truncate(500)
end
