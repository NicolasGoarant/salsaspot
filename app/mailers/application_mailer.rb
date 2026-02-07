# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: 'notifications@salsaspot.fr'
  layout 'mailer'
end
