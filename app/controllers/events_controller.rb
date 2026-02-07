# app/controllers/events_controller.rb
class EventsController < ApplicationController
  def index
    @events = Event.active.upcoming

    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @events }
    end
  end

  def show
    @event = Event.friendly.find(params[:id])

    # Charger les événements similaires dans la même ville
    @similar_events = Event.active
                           .upcoming
                           .where(city: @event.city)
                           .where.not(id: @event.id)
                           .limit(3)

    render layout: false
  end

  def new
    @event = Event.new
    render layout: false
  end

  def create
    @event = Event.new(event_params)
    @event.is_active = false # En attente de validation

    if @event.save
      # Envoyer email de notification à l'admin
      EventMailer.new_event_submission(@event).deliver_later

      redirect_to events_path, notice: "Merci ! Ton événement sera publié après validation. Tu recevras un email de confirmation."
    else
      render :new, layout: false, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :title, :description, :event_type, :level,
      :venue_name, :address, :city, :postal_code,
      :starts_at, :ends_at, :recurrence,
      :price, :is_free, :has_lessons, :lessons_time,
      :organizer_name, :organizer_email, :phone, :website, :facebook_url,
      dance_styles: [],
      photos: []
    )
  end
end
