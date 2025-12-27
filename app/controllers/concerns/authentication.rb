module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :require_account # Checking and setting account must happen first
    helper_method :authenticated?
    helper_method :email_address_pending_authentication

    etag { Current.identity.id if authenticated? }

    include Authentication::ViaMagicLink, LoginHelper
  end

  class_methods do
    def require_unauthenticated_access(**options)
      allow_unauthenticated_access **options
      before_action :redirect_authenticated_user, **options
    end

    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      before_action :resume_session, **options
      allow_unauthorized_access **options
    end

    def disallow_account_scope(**options)
      skip_before_action :require_account, **options
      before_action :redirect_tenanted_request, **options
    end
  end

  private
    def authenticated?
      Current.identity.present? || Current.user.present?
    end

    def require_account
      unless Current.account.present?
        respond_to do |format|
          format.html { redirect_to main_app.session_menu_path(script_name: nil) }
          format.json { head :unauthorized }
          format.all { head :unauthorized }
        end
      end
    end

    def require_authentication
      resume_session || authenticate_by_bearer_token || request_authentication
    end

    def resume_session
      if session = find_session_by_cookie
        set_current_session session
      end
    end

    def find_session_by_cookie
      Session.find_signed(cookies.signed[:session_token])
    end

    def authenticate_by_bearer_token
      if request.authorization.to_s.include?("Bearer")
        authenticate_or_request_with_http_token do |token|
          Rails.logger.info "[Auth] Checking token: #{token.first(5)}..."
          found = false
          if identity = Identity.find_by_permissable_access_token(token, method: request.method)
            Rails.logger.info "[Auth] Identity found: #{identity.id}"
            Current.identity = identity
            found = true
          elsif user = User.find_by(api_token: token)
            Rails.logger.info "[Auth] User found: #{user.role} (#{user.id})"
            Current.user = user
            Current.account = user.account
            found = true
          else
            Rails.logger.warn "[Auth] Token invalid or expired."
          end
          found
        end
      end
    end

    def request_authentication
      if Current.account.present?
        session[:return_to_after_authenticating] = request.url
      end

      respond_to do |format|
        format.html { redirect_to_login_url }
        format.json { head :unauthorized }
        format.all { head :unauthorized }
      end
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || landing_url
    end

    def redirect_authenticated_user
      redirect_to main_app.root_url if authenticated?
    end

    def redirect_tenanted_request
      return if request.format.json?
      redirect_to main_app.root_url if Current.account.present?
    end

    def start_new_session_for(identity)
      identity.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        set_current_session session
      end
    end

    def set_current_session(session)
      Current.session = session
      cookies.signed.permanent[:session_token] = { value: session.signed_id, httponly: true, same_site: :lax }
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_token)
    end

    def session_token
      cookies[:session_token]
    end
end
