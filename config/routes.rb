Rails.application.routes.draw do

  devise_for :users, skip: :all

  root to: 'open_api#ui'

  scope path: '/api/v1' do
    resources :users, only: :create
    resources :links, only: [:index, :create], param: :public_identifier do
      resource :analytics, controller: "link_analytics", only: :show
    end
  end

  get '/go/:public_identifier', to: 'redirect#show', as: :redirector
  get '/open_api/spec.json', to: 'open_api#spec', as: :open_api_spec

end
