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
