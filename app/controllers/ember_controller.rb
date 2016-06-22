# https://github.com/ghedamat/ember-deploy-demo/blob/master/edd-rails/app/controllers/demo_controller.rb
class EmberController < ApplicationController

  def index
    index_key = if Rails.env.development?
                  'ember-meetup:index:__development__'
                else
                  Sidekiq.redis { |r| "ember-cli:index:#{r.get('ember-cli:index:current')}" }
                end
    index = Sidekiq.redis { |r| r.get(index_key) }
    render text: process_index(index), layout: false
  end

  private

  def process_index(index)
    return "INDEX NOT FOUND" unless index

    index.sub!(/CSRF_TOKEN/, form_authenticity_token)
    index.sub!('/ember-cli-live-reload', 'http://localhost:4200/ember-cli-live-reload') if Rails.env.development?

    index
  end
end
