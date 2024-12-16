# frozen_string_literal: true

Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: "rails_health_check"

  # Render dynamic PWA files from app/views/pwa/*
  # (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root to: "welcome#index"

  resources "payouts", only: %i[create destroy show index new update]

  resources "projects", only: %i[create destroy show index new update] do
    resources "requirements", only: %i[create destroy show index new update] do
      resources "relations", only: %i[new create edit destroy]
    end
  end

  resources "workers", only: %i[create destroy show index new update]

  namespace "work" do
    resources "logs", only: %i[create destroy show index new update]
    resources "reviews", only: %i[create destroy show index new update]
  end
end
