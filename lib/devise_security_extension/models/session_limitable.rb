require 'devise_security_extension/hooks/session_limitable'

module Devise
  module Models
    # SessionLimited ensures, that there is only one session usable per account at once.
    # If someone logs in, and some other is logging in with the same credentials,
    # the session from the first one is invalidated and not usable anymore.
    # The first one is redirected to the sign page with a message, telling that 
    # someone used his credentials to sign in.
    module SessionLimitable
      extend ActiveSupport::Concern

      included do
        has_many :devise_sessions, :as => :session_limitable, :dependent => :destroy
      end

      def un_archive_unique_session(unique_session_id)
        unique_session = self.devise_sessions.where(:unique_session_id => unique_session_id)
        unique_session.delete_all if unique_session.present?
      end

      def archive_unique_session!(unique_session_id)
        if !sessions_on_limit? || (!reject_session_on_limit? && allow_create_session?) || sessions_allowed_count == 0
          archive_unique_session(unique_session_id)
        end
      end

      def update_last_request_at(unique_session_id)
        unique_session = self.devise_sessions.where(:unique_session_id => unique_session_id).first
        unique_session.update_attributes(:last_request_at => Time.now) if unique_session.present?
      end

      def accept_unique_session?(unique_session_id)
        self.devise_sessions.where(:unique_session_id => unique_session_id).count > 0
      end

      private
      def archive_unique_session(unique_session_id)
        unique_session = self.devise_sessions.where(:unique_session_id => unique_session_id).first_or_create
        unique_session.update_attributes(:last_request_at => Time.now)
      end

      def allow_create_session?
        reject_session_on_limit? ? self.devise_sessions.where('last_request_at <= ?', (Time.now - session_expiration)).destroy_all : self.devise_sessions.order(:id).reverse_order.offset(sessions_allowed_count).delete_all
      end

      def reject_session_on_limit?
        self.respond_to?(:sessions_reject_on_limit) && self.sessions_reject_on_limit.present? ? self.sessions_reject_on_limit : self.class.default_sessions_reject_on_limit
      end

      def sessions_on_limit?
        active_sessions_count >= sessions_allowed_count
      end

      def sessions_allowed_count
        if self.respond_to?(:sessions_count_limit) && self.sessions_count_limit.present?
          self.sessions_count_limit.to_i
        else
          self.class.default_sessions_limit.to_i
        end
      end

      def active_sessions_count
        self.devise_sessions.count
      end

      def session_expiration
        self.respond_to?(:sessions_expiration) && self.sessions_expiration.present? ? self.sessions_expiration.to_i : self.class.default_sessions_expiration.to_i
      end

      module ClassMethods
        ::Devise::Models.config(self, :default_sessions_limit, :default_sessions_reject_on_limit, :default_sessions_expiration)
      end
    end
  end
end