Rails.application.routes.draw do
  get '/(*path)' => 'ember_controller#index', as: :root, format: :html
end
