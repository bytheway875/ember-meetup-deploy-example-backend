# https://github.com/ghedamat/ember-deploy-demo/blob/master/edd-rails/app/controllers/demo_controller.rb
class EmberController < ApplicationController
  SHORT_UUID_V4_REGEXP = /\A[0-9a-f]{7}\z/i

  def index
    index_key = if Rails.env.development?
                  'ember-meetup:index:__development__'
                elsif fetch_revision
                  "ember-meetup:index:#{fetch_revision}"
                else
                  Sidekiq.redis { |r| "edd-cli:index:#{r.get('edd-cli:index:current')}" }
                end
    index = Sidekiq.redis { |r| r.get(index_key) }
    render text: process_index(index), layout: false
  end

  private

  def fetch_revision
    rev = params[:revision]
    rev if rev =~ SHORT_UUID_V4_REGEXP
  end

  def process_index(index)
    return "INDEX NOT FOUND" unless index

    index.sub!(/CSRF_TOKEN/, form_authenticity_token)
    index.sub!('/ember-cli-live-reload', 'http://localhost:4200/ember-cli-live-reload') if Rails.env.development?

    index
  end
end
