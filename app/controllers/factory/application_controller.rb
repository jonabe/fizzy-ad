module Factory
  class ApplicationController < ActionController::API
    # Skip CSRF for API
    # Permissive auth for smoke test
  end
end
