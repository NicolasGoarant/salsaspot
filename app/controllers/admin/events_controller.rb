class Admin::EventsController < ApplicationController
  layout false

  def index
    @events = Event.order(starts_at: :desc)
  end

  def show
    @event = Event.friendly.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.is_active = false # Brouillon par défaut
    if @event.save
      redirect_to admin_events_path, notice: "Événement créé en brouillon !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @event = Event.friendly.find(params[:id])
  end

  def update
    @event = Event.friendly.find(params[:id])
    if @event.update(event_params)
      redirect_to admin_events_path, notice: "Événement mis à jour !"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.friendly.find(params[:id])
    @event.destroy
    redirect_to admin_events_path, notice: "Événement supprimé !"
  end

  # Action pour activer/désactiver un événement
  def toggle
    @event = Event.friendly.find(params[:id])
    @event.update(is_active: !@event.is_active)

    status = @event.is_active ? "publié" : "mis en brouillon"
    redirect_to admin_events_path(filter: params[:filter]), notice: "\"#{@event.title}\" #{status} !"
  end

  # Page d'import Excel
  def import
    # Affiche le formulaire d'import
  end

  # Traitement de l'import Excel
  def import_excel
    unless params[:file].present?
      redirect_to import_admin_events_path, alert: "Veuillez sélectionner un fichier Excel."
      return
    end

    file = params[:file]

    unless file.content_type.in?(['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/vnd.ms-excel'])
      redirect_to import_admin_events_path, alert: "Format de fichier non supporté. Utilisez un fichier .xlsx"
      return
    end

    require 'roo'

    begin
      xlsx = Roo::Spreadsheet.open(file.path)
      sheet = xlsx.sheet('Danses NANCY') rescue xlsx.sheet(0)

      # Mapping des styles de danse
      dance_mapping = {
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

        # Ignorer les lignes vides ou les titres
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
            skipped += 1
            next
          end
        rescue
          skipped += 1
          next
        end

        # Parser l'heure
        horaires = row[:horaires].to_s
        start_hour = 21
        start_min = 0
        if horaires =~ /(\d{1,2})[Hh:](\d{2})?/
          start_hour = $1.to_i
          start_min = $2.to_i rescue 0
        end

        starts_at = DateTime.new(event_date.year, event_date.month, event_date.day, start_hour, start_min)

        # Parser les styles
        danse_code = row[:danses].to_s.strip.upcase.gsub(/[^A-Z]/, '')
        dance_styles = dance_mapping[danse_code] || []

        if dance_styles.empty?
          danse_str = row[:danses].to_s.downcase
          dance_styles << 'salsa' if danse_str.include?('salsa')
          dance_styles << 'bachata' if danse_str.include?('bachata')
          dance_styles << 'kizomba' if danse_str.include?('kizomba')
        end

        # Ignorer si pas SBK
        if dance_styles.empty?
          skipped += 1
          next
        end

        # Parser le prix
        tarif_str = row[:tarif].to_s.downcase
        price = 0.0
        is_free = false
        if tarif_str.include?('gratuit') || tarif_str.include?('libre')
          is_free = true
        elsif tarif_str =~ /(\d+(?:[.,]\d+)?)/
          price = $1.gsub(',', '.').to_f
        end

        # Parser le lieu
        lieu = row[:lieu].to_s.strip
        venue_name = lieu.split("\n").first || lieu
        city = 'Nancy'

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
        end

        # Titre
        organisateur = row[:organisateur].to_s.strip
        styles_str = dance_styles.map(&:capitalize).join(' & ')
        title = "#{styles_str} - #{venue_name}"
        title = "#{styles_str} par #{organisateur}" if organisateur.present? && venue_name.length < 5

        # URL Facebook
        facebook_url = nil
        lien = row[:lien].to_s
        if lien =~ /(https?:\/\/[^\s]+)/
          facebook_url = $1
        end

        # Description
        description = row[:details].to_s.strip
        description = "Organisé par #{organisateur}. #{description}" if organisateur.present? && description.present?
        description = "Organisé par #{organisateur}." if organisateur.present? && description.blank?

        # Cours inclus ?
        has_lessons = false
        full_text = "#{row[:horaires]} #{row[:details]}".downcase
        has_lessons = true if full_text.include?('cours') || full_text.include?('initiation') || full_text.include?('workshop')

        # Vérifier doublon
        existing = Event.where(starts_at: starts_at.beginning_of_day..starts_at.end_of_day)
                        .where("LOWER(venue_name) LIKE ?", "%#{venue_name.downcase.first(10)}%")
                        .first

        if existing
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
          is_free: is_free,
          description: description,
          facebook_url: facebook_url,
          dance_styles: dance_styles,
          is_active: false, # Brouillon par défaut
          has_lessons: has_lessons,
          organizer_name: organisateur.present? ? organisateur : nil
        )

        if event.save
          imported += 1
        else
          errors << "Ligne #{row_num}: #{event.errors.full_messages.join(', ')}"
        end
      end

      message = "Import terminé : #{imported} événements importés, #{skipped} ignorés."
      message += " Erreurs : #{errors.count}" if errors.any?

      redirect_to admin_events_path(filter: 'draft'), notice: message

    rescue => e
      redirect_to import_admin_events_path, alert: "Erreur lors de l'import : #{e.message}"
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :title, :description, :venue_name, :address, :city,
      :starts_at, :price, :facebook_url, :is_active, :has_lessons,
      :lessons_time, :latitude, :longitude,
      :level, :organizer_name, :is_free, dance_styles: []
    )
  end
end
