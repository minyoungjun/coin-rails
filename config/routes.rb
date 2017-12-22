Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "charts#index"
  get "charts/api"
  get "charts/mysql"
end
