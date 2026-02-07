# app/mailers/event_mailer.rb
class EventMailer < ApplicationMailer
  default from: 'notifications@salsaspot.fr'

  def new_event_submission(event)
    @event = event
    @admin_email = 'nicolas.goarant@gmail.com' # Remplace par ton email

    mail(
      to: @admin_email,
      subject: "🎉 Nouvelle soirée proposée : #{event.title}"
    )
  end
end
