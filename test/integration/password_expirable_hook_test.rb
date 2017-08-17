require 'test_helper'

class PasswordExpirableHookTest < ActionDispatch::IntegrationTest
  def password_expired
    @controller.user_session['password_expired']
  end

  test 'check if unique_session_id is set' do
    sign_in_as_user
    assert_not password_expired
  end

  test 'check if password_expired is set to true when need change' do
    User.any_instance.stubs(:need_change_password?).returns(true)
    sign_in_as_user
    assert password_expired
  end
end