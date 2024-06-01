Rails.application.routes.draw do
  root 'league#index'
  post 'simulate', to: 'league#simulate_week'
  post 'simulate_all', to: 'league#simulate_all'
end
