class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include BlockSearchEngineIndexing
  include CurrentRequest, CurrentTimezone, SetPlatform
  include RequestForgeryProtection
  include TurboFlash, ViewTransitions
  include RoutingHeaders

  skip_forgery_protection if Rails.env.development?

  etag { "v1" }
  stale_when_importmap_changes
  allow_browser versions: :modern
end
