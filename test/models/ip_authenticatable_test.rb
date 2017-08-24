require 'test_helper'
require 'test_models'

class IpAuthenticatableTest < ActiveSupport::TestCase
  setup do
    @ip_address_0 = generate_ip_address
    @ip_address_1 = generate_ip_address
    @user = create_user
    @user.class.authenticatable_ip_class.constantize.to_adapter.create!(owner: @user, ip_address: @ip_address_0)
  end

  test 'required_fields should contain the fields that Devise uses' do
    assert_same_content Devise::Models::IpAuthenticatable.required_fields(User), %i(authenticatable_ip_class)
  end

  test '#valid_for_ip_authentication?' do
    assert @user.valid_for_ip_authentication?(@ip_address_0)
    assert_not @user.valid_for_ip_authentication?(@ip_address_1)
  end

  test '.find_for_ip_authentication' do
    assert_equal @user, @user.class.find_for_ip_authentication({}, @ip_address_0)
    assert_not_equal @user, @user.class.find_for_ip_authentication({}, @ip_address_1)
  end
end
