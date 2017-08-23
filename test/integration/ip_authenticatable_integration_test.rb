require 'test_helper'

class IpAuthenticatableIntegrationTest < ActionDispatch::IntegrationTest
  def ip_authentication
    @controller.user_session['ip_authentication']
  end

  test 'sign in without authenticatable ip' do
    sign_in_as_user
    assert_not ip_authentication
    assert warden.authenticated?(:user)
  end

  test 'sign in with authenticatable ip only' do
    user = sign_in_as_user
    assert warden.authenticated?(:user)

    ip_address = generate_ip_address
    user.class.authenticatable_ip_class.constantize.to_adapter.create!(owner: user, ip_address: ip_address)

    visit destroy_user_session_path
    assert_not warden.authenticated?(:user)

    # Should redirect to session_path
    visit user_ip_authentication_path
    assert_current_url new_user_session_url
    assert_not warden.authenticated?(:user)

    stubs_with_ip(ip_address)

    visit user_ip_authentication_path
    click_button 'Log In'
    assert warden.authenticated?(:user)
  end

  test 'redirect to ip auth when not authenticated' do
    user = create_user
    ip_address = generate_ip_address
    user.class.authenticatable_ip_class.constantize.to_adapter.create!(owner: user, ip_address: ip_address)

    stubs_with_ip(ip_address)

    visit secret_data_path
    assert_current_url user_ip_authentication_path
  end
end