require 'recaptcha'

module DeviseSecurityExtension
  module Controllers
    module Recaptcha
      include ::Recaptcha::Verify

      def verify_captcha(options = {})
        if verify_recaptcha(options)
          yield if block_given?
        else
          flash[:alert] = t('devise.invalid_captcha') if is_flashing_format?
          raise(::Recaptcha::VerifyError)
        end
      end
    end
  end
end
