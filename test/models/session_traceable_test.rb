require 'test_helper'

class SessionTraceableTest < ActiveSupport::TestCase
  test 'required_fields should contain the fields that Devise uses' do
    assert_same_content Devise::Models::SessionTraceable.required_fields(User), [:session_traceable_class]
  end

  test 'should not raise exception' do
    assert_nothing_raised do
      current_user.log_traceable_request!(default_options)
    end
  end

  test 'token should not be blank' do
    assert_not_empty current_user.log_traceable_request!(default_options)
  end

  test 'token should be accepted' do
    user = current_user
    token = user.log_traceable_request!(default_options)
    assert user.accept_traceable_token?(token)
  end

  test 'expiring token should not raise exception' do
    user = current_user
    assert_nothing_raised do
      token = user.log_traceable_request!(default_options)
      user.expire_session_token(token)
    end
  end

  test 'expired token should not be accepted' do
    user = current_user
    token = user.log_traceable_request!(default_options)
    user.expire_session_token(token)

    assert_not user.accept_traceable_token?(token)
  end

  test 'last_accessed_at should be updated' do
    user = current_user
    token = user.log_traceable_request!(default_options)
    assert user.update_traceable_token(token)
  end

  test 'last_accessed_at should not equal to previous' do
    user = current_user
    token = user.log_traceable_request!(default_options)
    old_session = user.find_traceable_by_token(token)

    user.update_traceable_token(token)
    updated_session = user.find_traceable_by_token(token)

    assert_not_equal old_session.last_accessed_at, updated_session.last_accessed_at
  end
end