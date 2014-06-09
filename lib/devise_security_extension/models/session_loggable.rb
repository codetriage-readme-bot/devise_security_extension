require 'devise_security_extension/hooks/session_loggable'

module Devise
  module Models
    module SessionLoggable
      extend ActiveSupport::Concern

      included do
        has_many :devise_session_logs, :as => :session_loggable, :dependent => :destroy
      end

      def log_devise_session!(request, token)
        session_log = self.devise_session_logs.where(:unique_auth_token_id => token).first_or_initialize
        session_log.update_attributes(:last_accessed_at => Time.now,
                                      :ip_address => request.remote_ip,
                                      :user_agent => request.env['HTTP_USER_AGENT']
        ) if session_log.present? && session_log.unique_auth_token_valid
      end

      def update_last_accessed_at(token)
        session_log = self.devise_session_logs.where(:unique_auth_token_id => token).first
        session_log.update_attributes(:last_accessed_at => Time.now) if session_log.present?
      end

      def accept_devise_session_token?(request, token)
        self.devise_session_logs.where(
            :unique_auth_token_id => token,
            :ip_address => request.remote_ip,
            :unique_auth_token_valid => true
        ).count > 0
      end

      def invalidate_devise_session_log!(token)
        session_log = self.devise_session_logs.where(:unique_auth_token_id => token).first
        session_log.update_attributes(:unique_auth_token_valid => false) if session_log.present?
      end
    end
  end
end