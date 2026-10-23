# frozen_string_literal: true

Rails.application.routes.draw do
  mount LibraryDesign::Engine => "/library_design"

  root "home#index"
  get '/' => 'home#index', as: :home

  resources :houses, only: [:index, :show] do
    member do
      get 'research-services'
      get 'publications'
      get 'publications/unpublished', to: "houses#unpublished"
    end
  end

  resources :sections, only: [:index, :show] do
    member do
      get 'publications'
    end
  end
  resources :collections, only: [:index, :show]
  resources :concepts, only: [:index, :show] do
    member do
      get 'publications'
      get 'broader-terms'
      get 'narrower-terms'
    end
    collection do
      get 'promoted'
    end
  end

  resources :disclaimers, only: [:index, :show]
  resources :data_dashboards, path: 'data-dashboards', only: [:index, :show] do
    collection do
      get 'power-bi'
      get 'shiny'
    end
  end

  resources :research_services, path: 'research-services', only: [:index, :show] do
    member do
      get 'publications'
      get 'publications/unpublished'
      get 'sections'
      get 'promoted-concepts'
      get 'promoted-collections'
    end
  end

  resources :publications, only: [:index, :show] do
    collection do
      get 'unpublished'
    end
    resources :expressions, only: [:index, :show]
  end

  resources :people, only: [:index, :show]
  resources :geographic_areas, only: [:index, :show]

  #
  # Single sign on routes
  #
  get 'saml/login', to: "saml_sso/authentication#new", as: :saml_sso_login

  # For ShedCode, we return with a post, but PDS seem to return a get
  # So we need to cater for both
  get 'saml/callback', to: "saml_sso/authentication#create"
  post 'saml/callback', to: "saml_sso/authentication#create"

  # This just returns an empty page at the moment
  get 'saml/metadata', to: "saml_sso/authentication#metadata"

  # These come back from Entra if the user has logged out
  get 'saml/logout', to: "saml_sso/authentication#saml_logout", as: :entra_logout_callback
  post 'saml/logout', to: "saml_sso/authentication#saml_logout"

  # This is if the user has logged out
  get '/logout', to: "saml_sso/authentication#destroy", as: :saml_sso_logout
  delete '/logout', to: "saml_sso/authentication#destroy"

  # Note that this is in the design system set up
  get 'meta/cookies' => 'home#cookies', as: :meta_cookies
  get 'meta/examples' => 'home#examples', as: :examples
end
