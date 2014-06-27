require 'devise_security_extension/hooks/session_loggable'

module Devise
  module Models
    module SessionLoggable
      extend ActiveSupport::Concern

      included do
        has_many :devise_session_logs, :as => :session_loggable, :dependent => :destroy
      end

      def log_devise_session!(request)
        session_log = self.devise_session_logs.new(:unique_auth_token_id => generate_log_token,  :last_accessed_at => Time.now, :ip_address => request.remote_ip, :user_agent => request.env['HTTP_USER_AGENT'])
        session_log.save ? session_log.unique_auth_token_id : false
      end

      def update_log_last_accessed_at(token)
        find_by_session_log_token(token).update_attributes(:last_accessed_at => Time.now) if accept_session_log_token?(token)
      end

      def accept_session_log_token?(request, token)
        self.devise_session_logs.where(:unique_auth_token_id => token,:ip_address => request.remote_ip,:unique_auth_token_valid => true).count > 0
      end

      def invalidate_session_log!(token)
        self.find_by_session_log_token(token).update_attributes(:unique_auth_token_valid => false) if accept_session_log_token?(token)
      end

      def find_by_session_log_token(token)
        self.devise_session_logs.find :first, :conditions => {:unique_auth_token_id => token}
      end
      alias_method :accept_session_log_token?, :find_by_session_log_token

      private
      def generate_log_token
        loop do
          token = SecureRandom.urlsafe_base64(100, false)
          break token unless accept_session_log_token?(token)
        end
      end
    end
  end
end