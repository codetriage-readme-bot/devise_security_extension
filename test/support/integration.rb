require 'action_dispatch/testing/integration'

class ActionDispatch::IntegrationTest
  include Devise::TestHelpers

  def create_user(options={})
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

  def sign_in_as_user(options={}, &block)
    user = create_user(options)
    sign_in(user)
    yield if block_given?
    user
  end
end