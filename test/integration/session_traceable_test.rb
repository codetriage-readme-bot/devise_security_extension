require 'test_helper'

class SessionTraceableTest < ActionDispatch::IntegrationTest
  def unique_auth_token_id
    @controller.user_session['unique_auth_token_id']
  end

  test 'check if unique_auth_token_id is set' do
    sign_in_as_user
    assert_not_nil unique_auth_token_id
  end

  test 'sign out when unique_auth_token_id is not set' do
    sign_in_as_user
    @controller.user_session.delete('unique_auth_token_id')
    assert_not warden.authenticated?(:user)
  end

  test 'sign out when unique_auth_token_id is expired' do
    sign_in_as_user
    token = unique_auth_token_id

    assert create_user.expire_session_token(token)
    assert_not warden.authenticated?(:user)
  end
end