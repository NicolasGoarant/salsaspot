# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def discover
    render layout: false
  end

  def mentions_legales
    render layout: false
  end

  def politique
    render 'politique_confidentialite', layout: false
  end

  def cgu
    render layout: false
  end

  def contact
    render layout: false
  end

  def about
  render layout: false
  end

end
