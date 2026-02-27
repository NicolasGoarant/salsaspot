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
      redirect_to merci_events_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def merci
  end

  private

  def event_params
    params.require(:event).permit(
      :title, :description, :venue_name, :address, :city,
      :starts_at, :price, :event_url, :has_class,
      :class_start_time, :class_end_time, :latitude, :longitude,
      :level, :photo_url, dance_styles: []
    )
  end
end
