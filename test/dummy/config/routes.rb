Rails.application.routes.draw do
  # Users scope
  devise_for :users

  get :secret_data, to: 'home#secret_data'

  root to: 'home#index', via: %i(get post)
end
