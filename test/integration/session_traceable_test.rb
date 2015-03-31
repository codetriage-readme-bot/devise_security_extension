require 'test_helper'

class SessionTraceableTest < ActionDispatch::IntegrationTest
  def unique_auth_token_id
    @controller.user_session['unique_auth_token_id']
  end

  test 'check if unique_auth_token_id is set' do
    sign_in_as_user
    assert_not_nil unique_auth_token_id
  end

  test 'last_accessed_at are updated on each request' do
    user = create_user
    sign_in_as_user

    token = unique_auth_token_id
    session = user.find_traceable_by_token(token)
    first_accessed_at = session.last_accessed_at

    new_time = 2.seconds.from_now
    Time.stubs(:now).returns(new_time)
    visit root_path

    session.reload
    assert session.last_accessed_at > first_accessed_at
  end

  test 'session record should expire on sign out' do
    user = create_user
    sign_in_as_user
    token = unique_auth_token_id

    session = user.find_traceable_by_token(token)
    assert session.unique_auth_token_valid

    visit destroy_user_session_path
    session.reload
    assert_not session.unique_auth_token_valid
  end
end