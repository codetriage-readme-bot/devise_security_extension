require 'action_dispatch/testing/integration'

class ActionDispatch::IntegrationTest
  def warden
    request.env['warden']
  end

  def create_user(options = {})
    @user ||= begin
      user = User.create!(
        username: 'usertest',
        email: options[:email] || 'user@test.com',
        password: options[:password] || '12345678',
        password_confirmation: options[:password] || '12345678',
        created_at: Time.now.utc
      )
      user
    end
  end

  def sign_in_as_user(options = {})
    user = create_user(options)
    visit_with_option options[:visit], new_user_session_path
    fill_in 'email', with: options[:email] || 'user@test.com'
    fill_in 'password', with: options[:password] || '12345678'
    check 'remember me' if options[:remember_me] == true
    yield if block_given?
    click_button 'Log In'
    user
  end

  # Fix assert_redirect_to in integration sessions because they don't take into
  # account Middleware redirects.
  #
  def assert_redirected_to(url)
    assert [301, 302].include?(@integration_session.status),
           "Expected status to be 301 or 302, got #{@integration_session.status}"

    assert_url url, @integration_session.headers['Location']
  end

  def assert_current_url(expected)
    assert_url expected, current_url
  end

  def assert_url(expected, actual)
    assert_equal prepend_host(expected), prepend_host(actual)
  end

  def stubs_with_default_ip
    stubs_with_ip(default_options[:ip_address])
  end

  def stubs_with_ip(ip = nil)
    ip ||= generate_ip_address
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(ip)
  end
  alias_method :stubs_with_new_ip, :stubs_with_ip

  protected

  def visit_with_option(given, default)
    case given
    when String
      visit given
    when FalseClass
    # Do nothing
    else
      visit default
    end
  end

  def prepend_host(url)
    url = "http://#{request.host}#{url}" if url[0] == '/'
    url
  end
end
