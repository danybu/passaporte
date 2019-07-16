Rails.application.routes.draw do
  # get 'translations/lookup'
  devise_for :users
  root to: 'pages#home'

  get 'lookup', to: 'translations#lookup', as: :lookup
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
