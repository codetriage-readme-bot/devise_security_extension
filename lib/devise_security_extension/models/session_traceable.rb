require 'devise_security_extension/hooks/session_traceable'
require 'devise_security_extension/session_history'

module Devise
  module Models
    # SessionTraceable takes care of session trail in every authentication.
    # When a session expires after expiring the +token+, the user
    # will be asked for credentials again, it means, he/she will be redirected
    # to the sign in page.
    #
    # == Options
    #
    # SessionTraceable adds the following options to devise_for:
    #
    #   * +session_traceable_class+: to override +session_histories+ class.
    #
    # == Examples
    #
    #   user.log_traceable_request!
    #
    module SessionTraceable
      extend ActiveSupport::Concern

      included do
        has_many :session_histories, as: :session_traceable,
                 class_name: session_traceable_class, dependent: :destroy
      end

      def self.required_fields(klass)
        [:session_traceable_class, :paranoid_ip_verification]
      end

      # Create new traceable session
      #
      def log_traceable_request!(options = {})
        token = generate_traceable_token
        opts = options.merge unique_auth_token_id: token, last_accessed_at: Time.now.utc
        opts = session_traceable_condition(opts)
        session_traceable_adapter.create!(opts) && token
      end

      # Check if +token+ is valid
      #
      def accept_traceable_token?(token, options = {})
        opts = options.merge unique_auth_token_valid: true
        if paranoid_ip_verification
          opts[:ip_address] ||= nil
        else
          opts.delete(:ip_address)
        end
        find_traceable_by_token(token, opts).present?
      end

      # Update the `:last_accessed_at` to current time.
      #
      def update_traceable_token(token)
        record = find_traceable_by_token(token)
        record.last_accessed_at = Time.now.utc
        record.save(validate: false)
      end

      # Expire session matching the +token+
      # by setting `:unique_auth_token_valid` to false.
      #
      def expire_session_token(token)
        record = find_traceable_by_token(token)
        return unless record
        record.unique_auth_token_valid = false
        record.save(validate: false)
      end

      # Find the first instance, matching +token+, and optional +options+.
      #
      def find_traceable_by_token(token, options = {})
        opts = options.merge unique_auth_token_id: token
        opts = session_traceable_condition(opts)
        session_traceable_adapter.find_first opts
      end

      def paranoid_ip_verification
        self.class.paranoid_ip_verification
      end

      private

      def generate_traceable_token
        loop do
          token = Devise.friendly_token
          break token unless find_traceable_by_token(token).present?
        end
      end

      def session_traceable_adapter
        self.class.session_traceable_class.constantize.to_adapter
      end

      def session_traceable_condition(options = {})
        options.deep_merge session_traceable: self
      end

      module ClassMethods
        ::Devise::Models.config(self, :session_traceable_class, :paranoid_ip_verification)
      end
    end
  end
end