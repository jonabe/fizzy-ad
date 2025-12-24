# Base controller for API endpoints with Bearer token authentication
#
# Authentication uses User.api_token for stateless API access.
# All API controllers should inherit from this base class.
#
# Example:
#   curl -H "Authorization: Bearer <api_token>" http://localhost:3006/api/boards
#
class Api::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user!

  attr_reader :current_user

  private
    def authenticate_user!
      authenticate_or_request_with_http_token do |token, options|
        @current_user = User.find_by(api_token: token)
      end
    end
end
