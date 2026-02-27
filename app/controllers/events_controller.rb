class EventsController < ApplicationController
  layout false, only: [:index, :show]

  def index
    @events = Event.where(is_active: true).where("starts_at >= ?", Time.current).order(:starts_at)
    respond_to do |format|
      format.html
      format.json do
        render json: @events.map { |e|
          default_style = (e.dance_styles & ['salsa', 'bachata', 'kizomba']).first || 'salsa'
          fallback_photo = ActionController::Base.helpers.asset_path("#{default_style}.jpg")

          e.as_json.merge(
            price_display: e.price_display,
            photo_url: e.photo_url || fallback_photo,
            date_display: I18n.l(e.starts_at, format: "%A %d %B %Y, %Hh")
          )
        }
      end
    end
  end

  def show
    @event = Event.friendly.find(params[:id])
    @similar_events = Event.where(city: @event.city)
                          .where.not(id: @event.id)
                          .where(is_active: true)
                          .where("starts_at >= ?", Time.current)
                          .limit(3)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.is_active = false
    if @event.save
      # Notification par email
      EventMailer.new_event_notification(@event).deliver_later if defined?(EventMailer)
      redirect_to merci_events_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def merci
  end

  private

  def event_params
    params.require(:event).permit(
      :title, :description, :venue_name, :address, :city, :postal_code,
      :starts_at, :ends_at, :price, :is_free, :event_type,
      :has_lessons, :lessons_time, :recurrence,
      :level, :organizer_name, :phone, :organizer_email,
      :website, :facebook_url,
      :latitude, :longitude,
      dance_styles: [], photos: []
    )
  end
end
