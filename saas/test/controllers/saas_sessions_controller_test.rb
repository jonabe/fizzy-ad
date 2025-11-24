require "test_helper"

class SaasSessionsControllerTest < ActionDispatch::IntegrationTest
  test "create for a new user" do
    untenanted do
      assert_difference -> { Identity.count }, +1 do
        assert_difference -> { MagicLink.count }, +1 do
          post session_path,
            params: { email_address: "nonexistent-#{SecureRandom.hex(6)}@example.com" },
            headers: http_basic_auth_headers("testname", "testpassword")
        end
      end

      assert_redirected_to session_magic_link_path
    end
  end

  private
    def http_basic_auth_headers(user, password)
      { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
    end
end

