require 'devise_security_extension/controllers/recaptcha'

module DeviseSecurityExtension
  module Patches
    module UnlocksControllerCaptcha
      extend ActiveSupport::Concern
      include DeviseSecurityExtension::Controllers::Recaptcha

      included do
        before_action :verify_captcha, only: :create
        rescue_from ::Recaptcha::VerifyError, with: :invalid_captcha
      end

      private

      def invalid_captcha
        respond_with({}, location: new_unlock_path(resource_name)) && return
      end
    end
  end
end
