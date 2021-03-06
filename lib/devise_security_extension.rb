require 'active_record'
require 'active_support/core_ext/integer'
require 'active_support/ordered_hash'
require 'active_support/concern'
require 'devise'

module Devise
  # Should the password expire (e.g 3.months)
  mattr_accessor :expire_password_after
  @@expire_password_after = 3.months

  # Validate password for strongness
  mattr_accessor :password_regex
  @@password_regex = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/

  mattr_accessor :password_archivable_class
  @@password_archivable_class = 'Devise::OldPassword'

  # How often save old passwords in archive
  mattr_accessor :password_archiving_count
  @@password_archiving_count = 5

  # Deny old password (true, false, count)
  mattr_accessor :deny_old_passwords
  @@deny_old_passwords = true

  # enable email validation for :secure_validatable. (true, false, validation_options)
  # dependency: need an email validator like rails_email_validator
  mattr_accessor :email_validation
  @@email_validation = true

  # captcha integration for recover form
  mattr_accessor :captcha_for_recover
  @@captcha_for_recover = false

  # captcha integration for sign up form
  mattr_accessor :captcha_for_sign_up
  @@captcha_for_sign_up = false

  # captcha integration for sign in form
  mattr_accessor :captcha_for_sign_in
  @@captcha_for_sign_in = false

  # captcha integration for unlock form
  mattr_accessor :captcha_for_unlock
  @@captcha_for_unlock = false

  # security_question integration for recover form
  # this automatically enables captchas (captcha_for_recover, as fallback)
  mattr_accessor :security_question_for_recover
  @@security_question_for_recover = false

  # security_question integration for unlock form
  # this automatically enables captchas (captcha_for_unlock, as fallback)
  mattr_accessor :security_question_for_unlock
  @@security_question_for_unlock = false

  # security_question integration for confirmation form
  # this automatically enables captchas (captcha_for_confirmation, as fallback)
  mattr_accessor :security_question_for_confirmation
  @@security_question_for_confirmation = false

  # captcha integration for confirmation form
  mattr_accessor :captcha_for_confirmation
  @@captcha_for_confirmation = false

  # Time period for account expiry from last_activity_at
  mattr_accessor :expire_after
  @@expire_after = 90.days
  mattr_accessor :delete_expired_after
  @@delete_expired_after = 90.days

  mattr_accessor :session_traceable_class
  @@session_traceable_class = 'Devise::SessionHistory'

  mattr_accessor :session_limitable_class
  @@session_limitable_class = 'Devise::SessionLimit'

  mattr_accessor :limit_session_to
  @@limit_session_to = 1

  mattr_accessor :timeout_session_in
  @@timeout_session_in = nil

  mattr_accessor :reject_session_on_limit
  @@reject_session_on_limit = true

  mattr_accessor :paranoid_ip_verification
  @@paranoid_ip_verification = true

  mattr_accessor :authenticatable_ip_class
  @@authenticatable_ip_class = 'Devise::AuthenticatableIp'

  # The parent model all Devise models inherit from.
  # Defaults to ActionMailer::Base. This should be set early
  # in the initialization process and should be set to a string.
  mattr_accessor :parent_model
  @@parent_model = 'ActiveRecord::Base'
end

# an security extension for devise
module DeviseSecurityExtension
  autoload :Schema, 'devise_security_extension/schema'
  autoload :Patches, 'devise_security_extension/patches'

  module Controllers
    autoload :Helpers, 'devise_security_extension/controllers/helpers'
  end
end

# modules
Devise.add_module :ip_authenticatable, model: 'devise_security_extension/models/ip_authenticatable',
                                       strategy: true, controller: :ip_authentications,
                                       route: :ip_authentication
Devise.add_module :password_expirable, controller: :password_expirable,
                                       model: 'devise_security_extension/models/password_expirable',
                                       route: :password_expired
Devise.add_module :secure_validatable, model: 'devise_security_extension/models/secure_validatable'
Devise.add_module :password_archivable,
                  model: 'devise_security_extension/models/password_archivable'
Devise.add_module :session_limitable, model: 'devise_security_extension/models/session_limitable'
Devise.add_module :expirable, model: 'devise_security_extension/models/expirable'
Devise.add_module :security_questionable,
                  model: 'devise_security_extension/models/security_questionable'
Devise.add_module :session_traceable, model: 'devise_security_extension/models/session_traceable'

# requires
require 'devise_security_extension/routes'
require 'devise_security_extension/rails'
require 'devise_security_extension/orm/active_record'
