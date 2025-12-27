class My::IdentitiesController < ApplicationController
  disallow_account_scope

  def show
    @users = Current.identity&.users || [Current.user].compact
  end
end
