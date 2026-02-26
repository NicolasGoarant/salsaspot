# lib/tasks/import_events.rake
# Usage: rails import:excel FILE=path/to/file.xlsx

namespace :import do
  desc "Import events from Excel file (Danses Nancy format)"
  task excel: :environment do
    require 'roo'

    file_path = ENV['FILE']
    
    unless file_path
      puts "❌ Usage: rails import:excel FILE=path/to/file.xlsx"
      exit 1
    end

    unless File.exist?(file_path)
      puts "❌ Fichier non trouvé: #{file_path}"
      exit 1
    end

    puts "📂 Lecture du fichier: #{file_path}"
    
    xlsx = Roo::Spreadsheet.open(file_path)
    sheet = xlsx.sheet('Danses NANCY') rescue xlsx.sheet(0)
    
    # Mapping des styles de danse
    DANCE_MAPPING = {
      'S' => ['salsa'],
      'B' => ['bachata'],
      'K' => ['kizomba'],
      'SB' => ['salsa', 'bachata'],
      'SK' => ['salsa', 'kizomba'],
      'BK' => ['bachata', 'kizomba'],
      'SBK' => ['salsa', 'bachata', 'kizomba'],
      'SBKR' => ['salsa', 'bachata', 'kizomba'],
    }

    imported = 0
    skipped = 0
    errors = []

    # Parcourir les lignes (en sautant l'en-tête)
    (2..sheet.last_row).each do |row_num|
      row = {
        date: sheet.cell(row_num, 1),
        danses: sheet.cell(row_num, 2),
        horaires: sheet.cell(row_num, 3),
        lieu: sheet.cell(row_num, 4),
        organisateur: sheet.cell(row_num, 5),
        tarif: sheet.cell(row_num, 6),
        lien: sheet.cell(row_num, 7),
        details: sheet.cell(row_num, 8)
      }

      # Ignorer les lignes vides ou les titres de section
      next if row[:date].nil? || row[:danses].nil?
      date_str = row[:date].to_s
      next if date_str.include?('hebdomadaire') || date_str.include?('Événements') || date_str.include?('Tous les')
      
      # Parser la date
      begin
        if row[:date].is_a?(Date) || row[:date].is_a?(DateTime)
          event_date = row[:date].to_date
        elsif date_str =~ /(\d{4})-(\d{2})-(\d{2})/
          event_date = Date.parse(date_str)
        elsif date_str =~ /(\d{2})\/(\d{2})\/(\d{4})/
          event_date = Date.strptime(date_str, '%d/%m/%Y')
        else
          puts "⏭️  Ligne #{row_num}: Date non parsable '#{date_str}'"
          skipped += 1
          next
        end
      rescue => e
        puts "⏭️  Ligne #{row_num}: Erreur date '#{date_str}' - #{e.message}"
        skipped += 1
        next
      end

      # Parser l'heure de début
      horaires = row[:horaires].to_s
      start_hour = 21 # Par défaut
      start_min = 0
      
      if horaires =~ /(\d{1,2})[Hh:](\d{2})?/
        start_hour = $1.to_i
        start_min = $2.to_i rescue 0
      end

      starts_at = DateTime.new(event_date.year, event_date.month, event_date.day, start_hour, start_min)

      # Parser les styles de danse
      danse_code = row[:danses].to_s.strip.upcase.gsub(/[^A-Z]/, '')
      dance_styles = DANCE_MAPPING[danse_code] || []
      
      # Si pas de mapping, essayer de détecter
      if dance_styles.empty?
        danse_str = row[:danses].to_s.downcase
        dance_styles << 'salsa' if danse_str.include?('salsa') || danse_str.include?(' s ')
        dance_styles << 'bachata' if danse_str.include?('bachata') || danse_str.include?(' b ')
        dance_styles << 'kizomba' if danse_str.include?('kizomba') || danse_str.include?(' k ')
      end

      # Ignorer si pas de style SBK (swing, WCS, tango, etc.)
      if dance_styles.empty?
        puts "⏭️  Ligne #{row_num}: Style non SBK '#{row[:danses]}'"
        skipped += 1
        next
      end

      # Parser le prix
      tarif_str = row[:tarif].to_s.downcase
      price = 0.0
      if tarif_str.include?('gratuit') || tarif_str.include?('libre')
        price = 0.0
      elsif tarif_str =~ /(\d+(?:[.,]\d+)?)\s*€?/
        price = $1.gsub(',', '.').to_f
      end

      # Parser le lieu
      lieu = row[:lieu].to_s.strip
      venue_name = lieu.split("\n").first || lieu
      city = 'Nancy' # Par défaut

      # Détecter la ville dans le lieu
      if lieu.downcase.include?('laxou')
        city = 'Laxou'
      elsif lieu.downcase.include?('vandoeuvre')
        city = 'Vandœuvre-lès-Nancy'
      elsif lieu.downcase.include?('villers')
        city = 'Villers-lès-Nancy'
      elsif lieu.downcase.include?('malzéville')
        city = 'Malzéville'
      elsif lieu.downcase.include?('tomblaine')
        city = 'Tomblaine'
      elsif lieu.downcase.include?('pulnoy')
        city = 'Pulnoy'
      elsif lieu.downcase.include?('heillecourt')
        city = 'Heillecourt'
      end

      # Construire le titre
      organisateur = row[:organisateur].to_s.strip
      styles_str = dance_styles.map(&:capitalize).join(' & ')
      title = "#{styles_str} - #{venue_name}"
      title = "#{styles_str} par #{organisateur}" if organisateur.present? && venue_name.length < 5

      # URL de l'événement
      facebook_url = nil
      lien = row[:lien].to_s
      if lien =~ /(https?:\/\/[^\s]+)/
        facebook_url = $1
      end

      # Description
      description = row[:details].to_s.strip
      description = "Organisé par #{organisateur}. #{description}" if organisateur.present? && !description.include?(organisateur)

      # Vérifier si l'événement existe déjà
      existing = Event.where(starts_at: starts_at.beginning_of_day..starts_at.end_of_day)
                      .where("LOWER(venue_name) LIKE ?", "%#{venue_name.downcase.first(10)}%")
                      .first

      if existing
        puts "⏭️  Ligne #{row_num}: Événement existant '#{existing.title}'"
        skipped += 1
        next
      end

      # Créer l'événement
      event = Event.new(
        title: title,
        venue_name: venue_name,
        city: city,
        address: lieu,
        starts_at: starts_at,
        price: price,
        description: description,
        facebook_url: facebook_url,
        dance_styles: dance_styles,
        is_active: true,
        has_lessons: description.downcase.include?('cours') || description.downcase.include?('initiation') || description.downcase.include?('workshop')
      )

      if event.save
        puts "✅ Ligne #{row_num}: #{event.title} (#{event.starts_at.strftime('%d/%m/%Y')})"
        imported += 1
      else
        puts "❌ Ligne #{row_num}: #{event.errors.full_messages.join(', ')}"
        errors << { row: row_num, errors: event.errors.full_messages }
      end
    end

    puts "\n" + "=" * 50
    puts "📊 Résumé de l'import:"
    puts "   ✅ Importés: #{imported}"
    puts "   ⏭️  Ignorés: #{skipped}"
    puts "   ❌ Erreurs: #{errors.count}"
    puts "=" * 50

    if errors.any?
      puts "\n❌ Détail des erreurs:"
      errors.each do |err|
        puts "   Ligne #{err[:row]}: #{err[:errors].join(', ')}"
      end
    end
  end
end
