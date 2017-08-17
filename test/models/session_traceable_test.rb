require 'test_helper'
require 'test_models'

class TraceableTest < ActiveSupport::TestCase
  test 'required_fields should contain the fields that Devise uses' do
    assert_same_content Devise::Models::SessionTraceable.required_fields(User), %i(session_traceable_class paranoid_ip_verification)
  end

  test 'custom session_traceable should not raise exception' do
    swap Devise, session_traceable_class: 'CustomSessionHistory' do
      assert_nothing_raised do
        create_user.log_traceable_request!(default_options)
      end
    end
  end

  test 'inherited session_traceable should not raise exception' do
    swap Devise, session_traceable_class: 'InheritedSessionHistory' do
      assert_nothing_raised do
        create_user.log_traceable_request!(default_options)
      end
    end
  end

  test 'should not raise exception' do
    assert_nothing_raised do
      create_user.log_traceable_request!(default_options)
    end
  end

  test 'token should not be blank' do
    assert_not_empty create_user.log_traceable_request!(default_options)
  end

  test 'token should be paranoid with ip address' do
    user = create_user
    token = user.log_traceable_request!(default_options)

    assert_not user.accept_traceable_token?(token)
  end

  test 'token should be accepted' do
    user = create_user
    token = user.log_traceable_request!(default_options)
    assert user.accept_traceable_token?(token, default_options)
  end

  test 'token should be accepted even different ip if not paranoid_ip_verification' do
    swap Devise, paranoid_ip_verification: false do
      user = create_user
      token = user.log_traceable_request!(default_options)
      assert user.accept_traceable_token?(token, ip_address: '0.0.0.0')
    end
  end

  test 'expiring token should not raise exception' do
    user = create_user
    assert_nothing_raised do
      token = user.log_traceable_request!(default_options)
      user.expire_session_token(token)
    end
  end

  test 'expired token should not be accepted' do
    user = create_user
    token = user.log_traceable_request!(default_options)
    user.expire_session_token(token)

    assert_not user.accept_traceable_token?(token)
  end

  test 'expired token should not be accepted even different ip if not paranoid_ip_verification' do
    swap Devise, paranoid_ip_verification: false do
      user = create_user
      token = user.log_traceable_request!(default_options)
      user.expire_session_token(token)

      assert_not user.accept_traceable_token?(token, ip_address: '0.0.0.0')
    end
  end

  test 'last_accessed_at should be updated' do
    user = create_user
    token = user.log_traceable_request!(default_options)
    assert user.update_traceable_token(token)
  end

  test 'last_accessed_at should not equal to previous' do
    user = create_user
    token = user.log_traceable_request!(default_options)
    session = user.find_traceable_by_token(token)

    old_last_accessed = session.last_accessed_at

    new_time = 2.seconds.from_now
    Time.stubs(:now).returns(new_time)
    user.update_traceable_token(token)

    session.reload
    assert session.last_accessed_at > old_last_accessed
  end
end
