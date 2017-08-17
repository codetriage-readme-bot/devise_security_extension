require 'test_helper'
require 'test_models'

class TestPasswordArchivable < ActiveSupport::TestCase
  setup do
    User.stubs(:password_archiving_count).returns(2)
  end

  teardown do
    User.unstub(:password_archiving_count)
  end

  def set_password(user, password)
    user.password = password
    user.password_confirmation = password
    user.save!
  end

  test 'cannot use same password' do
    user = User.create password: 'password1', password_confirmation: 'password1'

    assert_raises(ActiveRecord::RecordInvalid) { set_password(user,  'password1') }
  end

  test 'cannot use archived passwords' do
    assert_equal 2, User.password_archiving_count

    user = User.create password: 'password1', password_confirmation: 'password1'
    assert_equal 0, OldPassword.count

    assert set_password(user, 'password2')
    assert_equal 1, OldPassword.count

    assert_raises(ActiveRecord::RecordInvalid) { set_password(user, 'password1') }

    assert set_password(user, 'password3')
    assert_equal 2, OldPassword.count

    # rotate first password out of archive
    assert set_password(user,  'password4')

    # archive count was 2, so first password should work again
    assert set_password(user,  'password1')
    assert set_password(user,  'password2')
  end

  test 'the option should be dynamic during runtime' do
    User.any_instance.stubs(:archive_count).returns(1)

    user = User.create password: 'password1', password_confirmation: 'password1'

    assert set_password(user, 'password2')

    assert_raises(ActiveRecord::RecordInvalid) { set_password(user,  'password2') }

    assert_raises(ActiveRecord::RecordInvalid) { set_password(user,  'password1') }
  end
end
