# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  # About et Discover ont leur propre design complet (landing pages standalone)
  # → on garde layout: false pour eux
  layout false, only: [:about, :discover]

  # Toutes les autres pages (contact, mentions, CGU, politique)
  # utilisent le layout application avec navbar + footer

  def discover
  end

  def mentions_legales
  end

  def politique
    render 'politique_confidentialite'
  end

  def cgu
  end

  def contact
  end

  def about
  end
end
