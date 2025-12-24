# Health check endpoint for monitoring and Docker health checks
#
# Returns JSON indicating database connectivity status.
# No authentication required.
#
# Example:
#   curl http://localhost:3006/health
#   => {"status":"ok"}
#
class HealthController < ActionController::API
  def show
    # Perform database health check by executing a simple query
    ActiveRecord::Base.connection.execute("SELECT 1")

    render json: { status: "ok" }
  rescue StandardError => e
    render json: { status: "error", message: e.message }, status: :service_unavailable
  end
end
