# frozen_string_literal: true

# Base class for controllers.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting,
  # and CSS :has.
  allow_browser versions: :modern

  before_action do
    user_name = nil

    authenticated =
      authenticate_with_http_digest do |name|
        user_name = name
        AppConfig.authentication[name]
      end

    if authenticated
      session[:user_name] = user_name
    else
      request_http_digest_authentication
    end
  end
end
