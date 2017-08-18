require 'devise_security_extension/controllers/recaptcha'

module DeviseSecurityExtension
  module Patches
    module RegistrationsControllerCaptcha
      extend ActiveSupport::Concern
      include DeviseSecurityExtension::Controllers::Recaptcha

      included do
        before_action :verify_captcha, only: :create
        rescue_from ::Recaptcha::VerifyError, with: :invalid_captcha
      end

      private

      def invalid_captcha
        build_resource(sign_up_params)
        resource.errors.add(:base, t('devise.invalid_captcha'))
        clean_up_passwords(resource)
        set_minimum_password_length
        respond_with(resource) && return
      end
    end
  end
end
