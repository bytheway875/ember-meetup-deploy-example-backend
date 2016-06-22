Rails.application.routes.draw do
  patch 'make/ember/current', to: 'ember#update'

  get '/(*path)' => 'ember#index', as: :root, format: :html
end
