# https://github.com/ghedamat/ember-deploy-demo/blob/master/edd-rails/app/controllers/demo_controller.rb
class EmberController < ApplicationController
  require 'open-uri'

  skip_before_action :authenticate_user!
  http_basic_authenticate_with name: ENV['EMBER_KEY'], password: ENV['EMBER_PASSWORD'], only: [:update]
  protect_from_forgery with: :null_session, only: [:update]

  KEY_PREFIX = 'ember-meetup:index'
  DEFAULT_REVISION = 'current-content'
  CLOUDFRONT_URL = ENV['CLOUDFRONT_URL']

  def index
    index = Rails.env.development? ? development_index : current_index

    render text: process_index(index), layout: false
  end

  def update
    index = open("#{cloudfront_url}index.html", 'rb').read
    Rails.cache.delete(cache_key)
    Rails.cache.write(cache_key, index, expires_in: 24.hours)
    render plain: Rails.cache.read(cache_key)
  end

  private

  def cache_key
    "#{KEY_PREFIX}:#{DEFAULT_REVISION}"
  end

  def development_index
    Sidekiq.redis { |r| r.get("#{KEY_PREFIX}:__development__") }
  end

  def current_index
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      open("#{CLOUDFRONT_URL}index.html", 'rb').read
    end
  end

  def process_index(index)
    return "INDEX NOT FOUND" unless index

    index.sub!(/CSRF_TOKEN/, form_authenticity_token)
    index.sub!('/ember-cli-live-reload', 'http://localhost:4200/ember-cli-live-reload') if Rails.env.development?

    index
  end

end
