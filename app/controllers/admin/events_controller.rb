# app/controllers/admin/events_controller.rb
class Admin::EventsController < ApplicationController
  layout false

  def index
    @events = Event.order(starts_at: :desc)
  end

  def show
    @event = Event.find(params[:id])
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update(event_params)
      redirect_to admin_events_path, notice: "Événement mis à jour !"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to admin_events_path, notice: "Événement supprimé !"
  end

  private

  def event_params
    params.require(:event).permit(
      :title, :description, :venue_name, :address, :city,
      :starts_at, :price, :event_url, :is_active, :has_class,
      :class_start_time, :class_end_time, :latitude, :longitude,
      :level, dance_styles: []
    )
  end
end
